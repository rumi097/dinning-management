package dsi.ruet.backend.marketplace;

import dsi.ruet.backend.marketplace.dto.MarketplacePostResponse;
import dsi.ruet.backend.marketplace.exception.MarketplaceException;
import dsi.ruet.backend.models.*;
import dsi.ruet.backend.models.enums.MarketplacePostStatus;
import dsi.ruet.backend.models.enums.TokenStatus;
import dsi.ruet.backend.models.enums.TransactionType;
import dsi.ruet.backend.common.dto.TokenResponse;
import dsi.ruet.backend.repositories.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MarketplaceService {

    private final MarketplaceRepository marketplaceRepository;
    private final TokenRepository tokenRepository;
    private final UserRepository userRepository;
    private final TokenTransactionRepository tokenTransactionRepository;
    private final WalletRepository walletRepository;
    private final CoinTransactionRepository coinTransactionRepository;

    private static final int PENDING_TIMEOUT_MINUTES = 15;

    // =====================================================================
    // CORE MARKETPLACE OPERATIONS
    // =====================================================================

    /**
     * List a token for sale on the marketplace.
     * <p>
     * Validates:
     * - Token exists and caller owns it
     * - Token status is AVAILABLE
     * - No existing OPEN/PENDING listing for this token
     * <p>
     * Side effects:
     * - Token status → LISTED
     * - New MarketplacePost created with status OPEN
     *
     * @param sellerId the user listing the token
     * @param tokenId  the token to list
     * @return the created marketplace post
     */
    @Transactional
    public MarketplacePostResponse createSellPost(Long sellerId, Long tokenId) {
        User seller = findUserOrThrow(sellerId);
        Token token = findTokenOrThrow(tokenId);

        // Must own the token
        if (!token.getOwner().getId().equals(sellerId)) {
            throw new MarketplaceException("You do not own this token");
        }

        // Token must be AVAILABLE (not USED, not already LISTED, not IN_QUEUE)
        if (token.getStatus() != TokenStatus.AVAILABLE) {
            throw new MarketplaceException(
                    "Token is not available for listing. Current status: " + token.getStatus());
        }

        // No duplicate active listing
        List<MarketplacePostStatus> activeStatuses =
                Arrays.asList(MarketplacePostStatus.OPEN, MarketplacePostStatus.PENDING);
        if (marketplaceRepository.existsByTokenIdAndStatusIn(tokenId, activeStatuses)) {
            throw new MarketplaceException("This token already has an active marketplace listing");
        }

        // Mark token as LISTED
        token.setStatus(TokenStatus.LISTED);
        tokenRepository.save(token);

        // Create the marketplace post
        MarketplacePost post = MarketplacePost.builder()
                .token(token)
                .seller(seller)
                .status(MarketplacePostStatus.OPEN)
                .build();
        post = marketplaceRepository.save(post);

        log.info("Token {} listed for sale by user {} (post {})", tokenId, sellerId, post.getId());
        return toResponse(post);
    }

    /**
     * Browse all OPEN marketplace posts for a specific hall.
     * Students can only see listings from their own hall.
     *
     * @param hallId the hall to filter by
     * @return list of open posts
     */
    @Transactional(readOnly = true)
    public List<MarketplacePostResponse> getOpenPosts(Long hallId) {
        return marketplaceRepository
                .findByStatusAndHallId(MarketplacePostStatus.OPEN, hallId)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get a single marketplace post by ID.
     *
     * @param postId the post id
     * @return the post details
     */
    @Transactional(readOnly = true)
    public MarketplacePostResponse getPostById(Long postId) {
        MarketplacePost post = findPostOrThrow(postId);
        return toResponse(post);
    }

    /**
     * Send a buy request for a marketplace listing.
     * <p>
     * Validates:
     * - Post is OPEN
     * - Buyer is not the seller
     * - Buyer is in the same hall
     * - Buyer doesn't already own a token for this meal
     * <p>
     * Side effects:
     * - Post status → PENDING
     * - Post buyer set, buyerRequestedAt recorded (15-min timer starts)
     *
     * @param postId  the marketplace post
     * @param buyerId the requesting buyer
     * @return updated post
     */
    @Transactional
    public MarketplacePostResponse sendBuyRequest(Long postId, Long buyerId, TransactionType paymentType) {
        MarketplacePost post = findPostOrThrow(postId);
        User buyer = findUserOrThrow(buyerId);

        // Post must be OPEN
        if (post.getStatus() != MarketplacePostStatus.OPEN) {
            throw new MarketplaceException(
                    "This listing is no longer available. Status: " + post.getStatus());
        }

        // Can't buy your own listing
        if (post.getSeller().getId().equals(buyerId)) {
            throw new MarketplaceException("You cannot buy your own listing");
        }

        // Must be same hall
        if (!buyer.getHall().getId().equals(post.getSeller().getHall().getId())) {
            throw new MarketplaceException("You can only buy tokens from your own hall");
        }

        // Buyer must not already own a token for this meal
        Long mealId = post.getToken().getMeal().getId();
        if (tokenRepository.existsByOwnerIdAndMealId(buyerId, mealId)) {
            throw new MarketplaceException("You already own a token for this meal");
        }

        // Set PENDING — 15-minute window starts
        post.setBuyer(buyer);
        post.setStatus(MarketplacePostStatus.PENDING);
        post.setPaymentType(paymentType);
        post.setBuyerRequestedAt(LocalDateTime.now());
        post = marketplaceRepository.save(post);

        log.info("Buy request on post {} by user {} — seller {} has 15 min to confirm",
                postId, buyerId, post.getSeller().getId());
        return toResponse(post);
    }

    /**
     * Seller confirms the token transfer to the buyer.
     * <p>
     * ATOMIC operation:
     * - Token ownership transferred to buyer
     * - Token status → AVAILABLE (new owner can use it)
     * - Post status → COMPLETED
     * - TokenTransaction record created
     *
     * @param postId   the marketplace post
     * @param sellerId the confirming seller
     * @return updated post
     */
    @Transactional
    public MarketplacePostResponse confirmTransfer(Long postId, Long sellerId) {
        MarketplacePost post = findPostOrThrow(postId);

        // Must be PENDING
        if (post.getStatus() != MarketplacePostStatus.PENDING) {
            throw new MarketplaceException(
                    "This listing is not pending confirmation. Status: " + post.getStatus());
        }

        // Only seller can confirm
        if (!post.getSeller().getId().equals(sellerId)) {
            throw new MarketplaceException("Only the seller can confirm the transfer");
        }

        User buyer = post.getBuyer();
        Token token = post.getToken();
        Long mealId = token.getMeal().getId();

        // Double-check: buyer hasn't acquired a token for this meal since the request
        if (tokenRepository.existsByOwnerIdAndMealId(buyer.getId(), mealId)) {
            // Roll back the pending request
            post.setBuyer(null);
            post.setStatus(MarketplacePostStatus.OPEN);
            post.setPaymentType(null);
            post.setBuyerRequestedAt(null);
            marketplaceRepository.save(post);
            throw new MarketplaceException(
                    "Buyer already owns a token for this meal. Request has been cancelled.");
        }

        // === ATOMIC TRANSFER ===
        User seller = post.getSeller();
        BigDecimal mealPrice = token.getMeal().getPrice();

        // Credit transfer only for TRANSACTION payment type
        // TOPUP means payment is handled outside the app — no wallet changes
        if (post.getPaymentType() == TransactionType.TRANSACTION) {
            // 1. Deduct from buyer's wallet
            Wallet buyerWallet = walletRepository.findById(buyer.getId())
                    .orElseThrow(() -> new MarketplaceException("Buyer wallet not found"));
            if (buyerWallet.getBalance().compareTo(mealPrice) < 0) {
                throw new MarketplaceException("Buyer has insufficient balance. Required: " + mealPrice);
            }
            buyerWallet.deduct(mealPrice);
            walletRepository.save(buyerWallet);

            // 2. Credit to seller's wallet
            Wallet sellerWallet = walletRepository.findById(seller.getId())
                    .orElseThrow(() -> new MarketplaceException("Seller wallet not found"));
            sellerWallet.credit(mealPrice);
            walletRepository.save(sellerWallet);

            // 3. Record coin transaction
            CoinTransaction coinTx = CoinTransaction.builder()
                    .sender(buyer)
                    .receiver(seller)
                    .amount(mealPrice.longValue())
                    .type(TransactionType.TRANSACTION)
                    .build();
            coinTransactionRepository.save(coinTx);
        }

        // 4. Transfer token ownership
        token.setOwner(buyer);
        token.setStatus(TokenStatus.AVAILABLE);
        tokenRepository.save(token);

        // 5. Complete the post
        post.setStatus(MarketplacePostStatus.COMPLETED);
        post = marketplaceRepository.save(post);

        // 6. Record the token transaction
        TokenTransaction transaction = TokenTransaction.builder()
                .sender(seller)
                .receiver(buyer)
                .token(token)
                .build();
        tokenTransactionRepository.save(transaction);

        log.info("Token {} transferred: {} → {} (post {}, price {})",
                token.getId(), seller.getId(), buyer.getId(), postId, mealPrice);
        return toResponse(post);
    }

    /**
     * Seller rejects a pending buy request.
     * Rolls the post back to OPEN so other buyers can request.
     *
     * @param postId   the marketplace post
     * @param sellerId the rejecting seller
     * @return updated post
     */
    @Transactional
    public MarketplacePostResponse rejectBuyRequest(Long postId, Long sellerId) {
        MarketplacePost post = findPostOrThrow(postId);

        if (post.getStatus() != MarketplacePostStatus.PENDING) {
            throw new MarketplaceException(
                    "This listing is not pending. Status: " + post.getStatus());
        }

        if (!post.getSeller().getId().equals(sellerId)) {
            throw new MarketplaceException("Only the seller can reject the buy request");
        }

        // Rollback to OPEN
        post.setBuyer(null);
        post.setStatus(MarketplacePostStatus.OPEN);
        post.setPaymentType(null);
        post.setBuyerRequestedAt(null);
        post = marketplaceRepository.save(post);

        log.info("Buy request rejected on post {} by seller {}", postId, sellerId);
        return toResponse(post);
    }

    /**
     * Buyer cancels their pending buy request.
     * Rolls the post back to OPEN.
     *
     * @param postId  the marketplace post
     * @param buyerId the cancelling buyer
     * @return updated post
     */
    @Transactional
    public MarketplacePostResponse cancelBuyRequest(Long postId, Long buyerId) {
        MarketplacePost post = findPostOrThrow(postId);

        if (post.getStatus() != MarketplacePostStatus.PENDING) {
            throw new MarketplaceException(
                    "This listing is not pending. Status: " + post.getStatus());
        }

        if (!post.getBuyer().getId().equals(buyerId)) {
            throw new MarketplaceException("Only the buyer can cancel the request");
        }

        // Rollback to OPEN
        post.setBuyer(null);
        post.setStatus(MarketplacePostStatus.OPEN);
        post.setPaymentType(null);
        post.setBuyerRequestedAt(null);
        post = marketplaceRepository.save(post);

        log.info("Buy request cancelled on post {} by buyer {}", postId, buyerId);
        return toResponse(post);
    }

    /**
     * Seller cancels their listing (only when OPEN — no pending buyer).
     * Token goes back to AVAILABLE.
     *
     * @param postId   the marketplace post
     * @param sellerId the seller cancelling
     */
    @Transactional
    public void cancelListing(Long postId, Long sellerId) {
        MarketplacePost post = findPostOrThrow(postId);

        if (post.getStatus() != MarketplacePostStatus.OPEN) {
            throw new MarketplaceException(
                    "Cannot cancel listing with status: " + post.getStatus()
                            + ". Wait for pending request to expire or be cancelled.");
        }

        if (!post.getSeller().getId().equals(sellerId)) {
            throw new MarketplaceException("Only the seller can cancel the listing");
        }

        // Restore token to AVAILABLE
        Token token = post.getToken();
        token.setStatus(TokenStatus.AVAILABLE);
        tokenRepository.save(token);

        // Remove listing
        marketplaceRepository.delete(post);

        log.info("Listing cancelled: post {} by seller {}", postId, sellerId);
    }

    // =====================================================================
    // SCHEDULED: 15-MINUTE TIMEOUT
    // =====================================================================

    /**
     * Expire PENDING buy requests older than 15 minutes.
     * Called by MarketplaceScheduler every 60 seconds.
     *
     * @return number of expired posts
     */
    @Transactional
    public int expireTimedOutRequests() {
        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(PENDING_TIMEOUT_MINUTES);
        List<MarketplacePost> timedOut = marketplaceRepository
                .findTimedOutPendingPosts(MarketplacePostStatus.PENDING, cutoff);

        for (MarketplacePost post : timedOut) {
            post.setBuyer(null);
            post.setStatus(MarketplacePostStatus.OPEN);
            post.setPaymentType(null);
            post.setBuyerRequestedAt(null);
            marketplaceRepository.save(post);
            log.info("Post {} timed out — rolled back to OPEN", post.getId());
        }

        if (!timedOut.isEmpty()) {
            log.info("Expired {} timed-out marketplace requests", timedOut.size());
        }
        return timedOut.size();
    }

    // =====================================================================
    // QUERY HELPERS (callable by teammates)
    // =====================================================================

    /**
     * Get all active listings by a seller (OPEN + PENDING).
     *
     * @param sellerId the seller
     * @return list of active listings
     */
    @Transactional(readOnly = true)
    public List<MarketplacePostResponse> getMyListings(Long sellerId) {
        List<MarketplacePostStatus> statuses =
                Arrays.asList(MarketplacePostStatus.OPEN, MarketplacePostStatus.PENDING);
        return marketplaceRepository.findBySellerIdAndStatusIn(sellerId, statuses)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get all pending purchases where this user is the buyer.
     *
     * @param buyerId the buyer
     * @return list of pending purchases
     */
    @Transactional(readOnly = true)
    public List<MarketplacePostResponse> getMyPurchases(Long buyerId) {
        return marketplaceRepository
                .findByBuyerIdAndStatus(buyerId, MarketplacePostStatus.PENDING)
                .stream()
                .map(this::toResponse)
                .collect(Collectors.toList());
    }

    /**
     * Check if a token is currently listed on the marketplace (OPEN or PENDING).
     * Useful for other modules (e.g., QR validation should reject LISTED tokens).
     *
     * @param tokenId the token to check
     * @return true if actively listed
     */
    @Transactional(readOnly = true)
    public boolean isTokenListed(Long tokenId) {
        List<MarketplacePostStatus> activeStatuses =
                Arrays.asList(MarketplacePostStatus.OPEN, MarketplacePostStatus.PENDING);
        return marketplaceRepository.existsByTokenIdAndStatusIn(tokenId, activeStatuses);
    }

    /**
     * Get the active marketplace post for a specific token (if any).
     *
     * @param tokenId the token
     * @return the active post, or null if none
     */
    @Transactional(readOnly = true)
    public MarketplacePostResponse getActivePostForToken(Long tokenId) {
        List<MarketplacePostStatus> activeStatuses =
                Arrays.asList(MarketplacePostStatus.OPEN, MarketplacePostStatus.PENDING);
        return marketplaceRepository
                .findFirstByTokenIdAndStatusIn(tokenId, activeStatuses)
                .map(this::toResponse)
                .orElse(null);
    }

    /**
     * Get all AVAILABLE tokens owned by the user (tokens they can list for sale).
     *
     * @param userId the user
     * @return list of available tokens
     */
    @Transactional(readOnly = true)
    public List<TokenResponse> getMyAvailableTokens(Long userId) {
        findUserOrThrow(userId); // validate user exists
        return tokenRepository.findByOwnerIdAndStatus(userId, TokenStatus.AVAILABLE)
                .stream()
                .map(this::toTokenResponse)
                .collect(Collectors.toList());
    }

    // =====================================================================
    // PRIVATE HELPERS
    // =====================================================================

    private User findUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new MarketplaceException("User not found: " + userId));
    }

    private Token findTokenOrThrow(Long tokenId) {
        return tokenRepository.findById(tokenId)
                .orElseThrow(() -> new MarketplaceException("Token not found: " + tokenId));
    }

    private MarketplacePost findPostOrThrow(Long postId) {
        return marketplaceRepository.findById(postId)
                .orElseThrow(() -> new MarketplaceException("Marketplace post not found: " + postId));
    }

    private MarketplacePostResponse toResponse(MarketplacePost post) {
        Token token = post.getToken();
        return MarketplacePostResponse.builder()
                .id(post.getId())
                .tokenId(token.getId())
                .mealType(token.getMeal().getMealType().name())
                .mealDate(token.getMeal().getMealDate().toString())
                .mealMenu(token.getMeal().getMenu())
                .mealPrice(token.getMeal().getPrice().longValue())
                .sellerId(post.getSeller().getId())
                .sellerName(post.getSeller().getName())
                .buyerId(post.getBuyer() != null ? post.getBuyer().getId() : null)
                .buyerName(post.getBuyer() != null ? post.getBuyer().getName() : null)
                .status(post.getStatus().name())
                .paymentType(post.getPaymentType() != null ? post.getPaymentType().name() : null)
                .createdAt(post.getCreatedAt() != null ? post.getCreatedAt().toString() : null)
                .buyerRequestedAt(post.getBuyerRequestedAt() != null
                        ? post.getBuyerRequestedAt().toString() : null)
                .build();
    }

    private TokenResponse toTokenResponse(Token token) {
        return TokenResponse.builder()
                .id(token.getId())
                .mealId(token.getMeal().getId())
                .mealType(token.getMeal().getMealType().name())
                .mealDate(token.getMeal().getMealDate().toString())
                .menu(token.getMeal().getMenu())
                .price(token.getMeal().getPrice().longValue())
                .status(token.getStatus().name())
                .build();
    }
}
