package dsi.ruet.backend.marketplace;

import dsi.ruet.backend.common.dto.ApiResponse;
import dsi.ruet.backend.common.dto.TokenResponse;
import dsi.ruet.backend.marketplace.dto.BuyRequest;
import dsi.ruet.backend.marketplace.dto.MarketplacePostResponse;
import dsi.ruet.backend.marketplace.dto.SellRequest;
import dsi.ruet.backend.models.User;
import dsi.ruet.backend.models.enums.TransactionType;
import dsi.ruet.backend.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/marketplace")
@RequiredArgsConstructor
public class MarketplaceController {

    private final MarketplaceService marketplaceService;
    private final UserRepository userRepository;

    // ── Browse ───────────────────────────────────────────────────────────

    /**
     * GET /api/v1/marketplace/posts
     * Browse all OPEN listings in the caller's hall.
     */
    @GetMapping("/posts")
    public ResponseEntity<ApiResponse<List<MarketplacePostResponse>>> getOpenPosts(
            @RequestHeader("X-User-Id") Long userId) {
        Long hallId = getHallIdForUser(userId);
        List<MarketplacePostResponse> posts = marketplaceService.getOpenPosts(hallId);
        return ResponseEntity.ok(ApiResponse.success(posts, "Open marketplace posts"));
    }

    /**
     * GET /api/v1/marketplace/my-tokens
     * Get the caller's AVAILABLE tokens (tokens they can list for sale).
     */
    @GetMapping("/my-tokens")
    public ResponseEntity<ApiResponse<List<TokenResponse>>> getMyTokens(
            @RequestHeader("X-User-Id") Long userId) {
        List<TokenResponse> tokens = marketplaceService.getMyAvailableTokens(userId);
        return ResponseEntity.ok(ApiResponse.success(tokens, "Your available tokens"));
    }

    // ── Sell ─────────────────────────────────────────────────────────────

    /**
     * POST /api/v1/marketplace/sell
     * List a token for sale.
     * Body: { "tokenId": 1 }
     */
    @PostMapping("/sell")
    public ResponseEntity<ApiResponse<MarketplacePostResponse>> sell(
            @RequestHeader("X-User-Id") Long userId,
            @RequestBody SellRequest request) {
        MarketplacePostResponse post =
                marketplaceService.createSellPost(userId, request.getTokenId());
        return ResponseEntity.ok(ApiResponse.success(post, "Token listed for sale"));
    }

    /**
     * DELETE /api/v1/marketplace/{id}
     * Seller cancels their listing (only when OPEN — no pending buyer).
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> cancelListing(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long id) {
        marketplaceService.cancelListing(id, userId);
        return ResponseEntity.ok(ApiResponse.success(null, "Listing cancelled"));
    }

    // ── Buy ──────────────────────────────────────────────────────────────

    /**
     * POST /api/v1/marketplace/buy
     * Send a buy request (sets post to PENDING, 15-min timer starts).
     * Body: { "postId": 1 }
     */
    @PostMapping("/buy")
    public ResponseEntity<ApiResponse<MarketplacePostResponse>> buyRequest(
            @RequestHeader("X-User-Id") Long userId,
            @RequestBody BuyRequest request) {
        TransactionType paymentType = TransactionType.valueOf(request.getPaymentType().toUpperCase());
        MarketplacePostResponse post = marketplaceService.sendBuyRequest(request.getPostId(), userId, paymentType);
        return ResponseEntity.ok(ApiResponse.success(post, "Buy request sent — seller has 15 min to confirm"));
    }

    /**
     * POST /api/v1/marketplace/purchases/{id}/cancel
     * Buyer cancels their pending buy request.
     */
    @PostMapping("/purchases/{id}/cancel")
    public ResponseEntity<ApiResponse<MarketplacePostResponse>> cancelRequest(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long id) {
        MarketplacePostResponse post = marketplaceService.cancelBuyRequest(id, userId);
        return ResponseEntity.ok(ApiResponse.success(post, "Buy request cancelled"));
    }

    // ── Seller Actions on Listings ───────────────────────────────────────

    /**
     * POST /api/v1/marketplace/listings/{id}/confirm
     * Seller confirms the token transfer (atomic ownership swap + credit transfer).
     */
    @PostMapping("/listings/{id}/confirm")
    public ResponseEntity<ApiResponse<MarketplacePostResponse>> confirmTransfer(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long id) {
        MarketplacePostResponse post = marketplaceService.confirmTransfer(id, userId);
        return ResponseEntity.ok(ApiResponse.success(post, "Token transferred successfully"));
    }

    /**
     * POST /api/v1/marketplace/listings/{id}/reject
     * Seller rejects the pending buy request (rolls back to OPEN).
     */
    @PostMapping("/listings/{id}/reject")
    public ResponseEntity<ApiResponse<MarketplacePostResponse>> rejectRequest(
            @RequestHeader("X-User-Id") Long userId,
            @PathVariable Long id) {
        MarketplacePostResponse post = marketplaceService.rejectBuyRequest(id, userId);
        return ResponseEntity.ok(ApiResponse.success(post, "Buy request rejected"));
    }

    // ── My Listings & Purchases ──────────────────────────────────────────

    /**
     * GET /api/v1/marketplace/my-listings
     * Get the caller's active listings (OPEN + PENDING).
     */
    @GetMapping("/my-listings")
    public ResponseEntity<ApiResponse<List<MarketplacePostResponse>>> myListings(
            @RequestHeader("X-User-Id") Long userId) {
        List<MarketplacePostResponse> listings = marketplaceService.getMyListings(userId);
        return ResponseEntity.ok(ApiResponse.success(listings, "Your listings"));
    }

    /**
     * GET /api/v1/marketplace/my-purchases
     * Get the caller's pending purchase requests.
     */
    @GetMapping("/my-purchases")
    public ResponseEntity<ApiResponse<List<MarketplacePostResponse>>> myPurchases(
            @RequestHeader("X-User-Id") Long userId) {
        List<MarketplacePostResponse> purchases = marketplaceService.getMyPurchases(userId);
        return ResponseEntity.ok(ApiResponse.success(purchases, "Your purchase requests"));
    }

    // ── Internal Helper ──────────────────────────────────────────────────

    private Long getHallIdForUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));
        return user.getHall().getId();
    }
}
