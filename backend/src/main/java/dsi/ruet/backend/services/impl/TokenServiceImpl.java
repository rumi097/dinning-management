package dsi.ruet.backend.services.impl;

import dsi.ruet.backend.dto.token.*;
import dsi.ruet.backend.exception.ResourceNotFoundException;
import dsi.ruet.backend.models.*;
import dsi.ruet.backend.repositories.*;
import dsi.ruet.backend.services.TokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Implementation of {@link TokenService}.
 * Handles all token-related business logic including purchase,
 * QR generation/validation, usage tracking, and transfers.
 */
@Service
public class TokenServiceImpl implements TokenService {

    @Autowired
    private TokenRepository tokenRepository;

    @Autowired
    private MealRepository mealRepository;

    @Autowired
    private WalletRepository walletRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TokenTransactionRepository tokenTransactionRepository;

    /* ==================== 1. Purchase Token ==================== */

    @Override
    @Transactional
    public TokenResponse purchaseToken(PurchaseTokenRequest request, User currentUser) {
        // 1. Fetch the meal
        Meal meal = mealRepository.findById(request.getMealId())
                .orElseThrow(() -> new ResourceNotFoundException("Meal not found with ID: " + request.getMealId()));

        // 2. Check purchase deadline
        if (LocalDateTime.now().isAfter(meal.getPurchaseDeadline())) {
            throw new IllegalStateException("Purchase deadline has passed for this meal.");
        }

        // 3. Prevent duplicate token purchase (one token per meal per user)
        if (tokenRepository.existsByOwnerAndMeal(currentUser, meal)) {
            throw new IllegalStateException("You have already purchased a token for this meal.");
        }

        // 4. Fetch wallet and check balance
        Wallet wallet = walletRepository.findByUserId(currentUser.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Wallet not found. Please contact admin."));

        if (wallet.getBalance().compareTo(meal.getPrice()) < 0) {
            throw new IllegalStateException("Insufficient wallet balance. Required: " + meal.getPrice()
                    + ", Available: " + wallet.getBalance());
        }

        // 5. Deduct wallet balance
        wallet.setBalance(wallet.getBalance().subtract(meal.getPrice()));
        walletRepository.save(wallet);

        // 6. Create the token
        Token token = new Token();
        token.setMeal(meal);
        token.setOwner(currentUser);
        token.setStatus(TokenStatus.ACTIVE);
        token = tokenRepository.save(token);

        // 7. Generate a unique QR code string and save it
        String qrCode = "TOKEN:" + token.getId() + ":" + UUID.randomUUID();
        token.setQrCode(qrCode);
        token = tokenRepository.save(token);

        // 8. Record the purchase as a transaction (sender = receiver = buyer for purchases)
        TokenTransaction transaction = new TokenTransaction();
        transaction.setSender(currentUser);
        transaction.setReceiver(currentUser);
        transaction.setToken(token);
        tokenTransactionRepository.save(transaction);

        // 9. Return token info
        return mapToTokenResponse(token);
    }

    /* ==================== 2. View My Tokens ==================== */

    @Override
    public List<TokenResponse> getMyTokens(User currentUser) {
        List<Token> tokens = tokenRepository.findByOwnerOrderByCreatedAtDesc(currentUser);
        return tokens.stream().map(this::mapToTokenResponse).collect(Collectors.toList());
    }

    /* ==================== 3. View Token by ID ==================== */

    @Override
    public TokenResponse getTokenById(Long tokenId, User currentUser) {
        Token token = tokenRepository.findById(tokenId)
                .orElseThrow(() -> new ResourceNotFoundException("Token not found with ID: " + tokenId));

        // Only the owner or an ADMIN can view the token
        if (!token.getOwner().getId().equals(currentUser.getId())
                && !"ADMIN".equals(currentUser.getRole())) {
            throw new IllegalStateException("You do not have permission to view this token.");
        }

        return mapToTokenResponse(token);
    }

    /* ==================== 4. Generate QR Code ==================== */

    @Override
    @Transactional
    public QrResponse generateQr(Long tokenId, User currentUser) {
        Token token = tokenRepository.findById(tokenId)
                .orElseThrow(() -> new ResourceNotFoundException("Token not found with ID: " + tokenId));

        // Verify token belongs to the current user
        if (!token.getOwner().getId().equals(currentUser.getId())) {
            throw new IllegalStateException("You can only generate QR codes for your own tokens.");
        }

        // Token must be ACTIVE
        if (token.getStatus() != TokenStatus.ACTIVE) {
            throw new IllegalStateException("QR code can only be generated for ACTIVE tokens. Current status: " + token.getStatus());
        }

        // Generate QR code string if not already generated
        if (token.getQrCode() == null || token.getQrCode().isEmpty()) {
            String qrCode = "TOKEN:" + token.getId() + ":" + UUID.randomUUID();
            token.setQrCode(qrCode);
            token = tokenRepository.save(token);
        }

        // Generate Base64 QR image
        String qrImageBase64 = generateQrImageBase64(token.getQrCode());

        return QrResponse.builder()
                .tokenId(token.getId())
                .qrCode(token.getQrCode())
                .qrImageBase64(qrImageBase64)
                .build();
    }

    /* ==================== 5. Validate QR Code ==================== */

    @Override
    public QrValidationResponse validateQr(ValidateQrRequest request) {
        String qrData = request.getQrData();

        // Parse the QR data format: TOKEN:<id>:<uuid>
        if (qrData == null || !qrData.startsWith("TOKEN:")) {
            return QrValidationResponse.builder()
                    .valid(false)
                    .message("Invalid QR code format.")
                    .build();
        }

        // Find the token by QR code
        Token token = tokenRepository.findByQrCode(qrData).orElse(null);

        if (token == null) {
            return QrValidationResponse.builder()
                    .valid(false)
                    .message("Token not found for this QR code.")
                    .build();
        }

        // Check if already used
        if (token.getStatus() == TokenStatus.USED) {
            return QrValidationResponse.builder()
                    .valid(false)
                    .tokenId(token.getId())
                    .ownerName(token.getOwner().getName())
                    .mealType(token.getMeal().getMealType())
                    .mealDate(token.getMeal().getMealDate())
                    .status(token.getStatus().name())
                    .message("Token has already been used.")
                    .build();
        }

        // Check if token is active
        if (token.getStatus() != TokenStatus.ACTIVE) {
            return QrValidationResponse.builder()
                    .valid(false)
                    .tokenId(token.getId())
                    .ownerName(token.getOwner().getName())
                    .mealType(token.getMeal().getMealType())
                    .mealDate(token.getMeal().getMealDate())
                    .status(token.getStatus().name())
                    .message("Token is not active. Status: " + token.getStatus())
                    .build();
        }

        // Check correct meal date (token should be for today's meal)
        Meal meal = token.getMeal();
        if (!meal.getMealDate().equals(java.time.LocalDate.now())) {
            return QrValidationResponse.builder()
                    .valid(false)
                    .tokenId(token.getId())
                    .ownerName(token.getOwner().getName())
                    .mealType(meal.getMealType())
                    .mealDate(meal.getMealDate())
                    .status(token.getStatus().name())
                    .message("Token is not for today's meal. Meal date: " + meal.getMealDate())
                    .build();
        }

        // Token is valid
        return QrValidationResponse.builder()
                .valid(true)
                .tokenId(token.getId())
                .ownerName(token.getOwner().getName())
                .mealType(meal.getMealType())
                .mealDate(meal.getMealDate())
                .status(token.getStatus().name())
                .message("Token is valid. Ready to serve.")
                .build();
    }

    /* ==================== 6. Mark Token as Used ==================== */

    @Override
    @Transactional
    public TokenResponse markTokenUsed(Long tokenId) {
        Token token = tokenRepository.findById(tokenId)
                .orElseThrow(() -> new ResourceNotFoundException("Token not found with ID: " + tokenId));

        // Prevent reuse
        if (token.getStatus() == TokenStatus.USED) {
            throw new IllegalStateException("Token has already been used.");
        }

        if (token.getStatus() != TokenStatus.ACTIVE) {
            throw new IllegalStateException("Only ACTIVE tokens can be marked as used. Current status: " + token.getStatus());
        }

        token.setStatus(TokenStatus.USED);
        token.setUsedAt(LocalDateTime.now());
        token = tokenRepository.save(token);

        return mapToTokenResponse(token);
    }

    /* ==================== 7. Transfer Token ==================== */

    @Override
    @Transactional
    public TokenResponse transferToken(TransferTokenRequest request) {
        Token token = tokenRepository.findById(request.getTokenId())
                .orElseThrow(() -> new ResourceNotFoundException("Token not found with ID: " + request.getTokenId()));

        User sender = token.getOwner();

        // Token must be ACTIVE
        if (token.getStatus() != TokenStatus.ACTIVE) {
            throw new IllegalStateException("Only ACTIVE tokens can be transferred. Current status: " + token.getStatus());
        }

        // Find the receiver
        User receiver = userRepository.findByEmail(request.getReceiverEmail())
                .orElseThrow(() -> new ResourceNotFoundException("Receiver not found with email: " + request.getReceiverEmail()));

        // Cannot transfer to yourself
        if (sender.getId().equals(receiver.getId())) {
            throw new IllegalStateException("Cannot transfer a token to yourself.");
        }

        // Prevent duplicate: receiver should not already have a token for this meal
        if (tokenRepository.existsByOwnerAndMeal(receiver, token.getMeal())) {
            throw new IllegalStateException("Receiver already has a token for this meal.");
        }

        // Transfer ownership
        token.setOwner(receiver);

        // Regenerate QR code for the new owner
        token.setQrCode("TOKEN:" + token.getId() + ":" + UUID.randomUUID());
        token = tokenRepository.save(token);

        // Record the transfer transaction
        TokenTransaction transaction = new TokenTransaction();
        transaction.setSender(sender);
        transaction.setReceiver(receiver);
        transaction.setToken(token);
        tokenTransactionRepository.save(transaction);

        return mapToTokenResponse(token);
    }

    /* ==================== Helper Methods ==================== */

    /**
     * Maps a Token entity to a TokenResponse DTO.
     */
    private TokenResponse mapToTokenResponse(Token token) {
        Meal meal = token.getMeal();
        return TokenResponse.builder()
                .id(token.getId())
                .mealId(meal.getId())
                .mealType(meal.getMealType())
                .mealDate(meal.getMealDate())
                .price(meal.getPrice())
                .menu(meal.getMenu())
                .status(token.getStatus().name())
                .ownerName(token.getOwner().getName())
                .createdAt(token.getCreatedAt())
                .usedAt(token.getUsedAt())
                .build();
    }

    /**
     * Generates a Base64-encoded PNG QR code image using Java 2D graphics.
     * This is a simple text-based QR representation.
     * For production, consider using ZXing library for proper QR codes.
     */
    private String generateQrImageBase64(String qrData) {
        try {
            int size = 200;
            BufferedImage image = new BufferedImage(size, size, BufferedImage.TYPE_INT_RGB);
            Graphics2D g = image.createGraphics();

            // White background
            g.setColor(Color.WHITE);
            g.fillRect(0, 0, size, size);

            // Black border
            g.setColor(Color.BLACK);
            g.drawRect(0, 0, size - 1, size - 1);

            // Draw QR data as text (simplified representation)
            g.setFont(new Font("Monospaced", Font.PLAIN, 10));
            g.setColor(Color.BLACK);

            // Simple hash-based pattern to create visual distinctiveness
            int cellSize = 8;
            int offset = 20;
            int gridSize = (size - 2 * offset) / cellSize;
            int hash = qrData.hashCode();

            for (int row = 0; row < gridSize; row++) {
                for (int col = 0; col < gridSize; col++) {
                    // Deterministic pattern based on data hash
                    int val = (hash ^ (row * 31 + col * 17)) & 0xFF;
                    if (val % 2 == 0) {
                        g.fillRect(offset + col * cellSize, offset + row * cellSize, cellSize, cellSize);
                    }
                }
            }

            // Draw TOKEN text at bottom
            g.setColor(Color.BLACK);
            g.setFont(new Font("SansSerif", Font.BOLD, 9));
            g.drawString("TOKEN-" + qrData.substring(6, Math.min(20, qrData.length())), 10, size - 5);

            g.dispose();

            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(image, "PNG", baos);
            return Base64.getEncoder().encodeToString(baos.toByteArray());
        } catch (Exception e) {
            // Fall back to returning the raw QR data if image generation fails
            return Base64.getEncoder().encodeToString(qrData.getBytes());
        }
    }
}
