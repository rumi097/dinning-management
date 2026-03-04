package dsi.ruet.backend.controllers;

import dsi.ruet.backend.dto.ApiResponse;
import dsi.ruet.backend.dto.student.TransactionHistoryResponse;
import dsi.ruet.backend.marketplace.MarketplacePost;
import dsi.ruet.backend.marketplace.MarketplaceRepository;
import dsi.ruet.backend.models.*;
import dsi.ruet.backend.models.enums.TransactionType;
import dsi.ruet.backend.repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * REST controller for student-facing read operations.
 * Wallet balance, today's meals, available meals for purchase.
 */
@RestController
@RequestMapping("/students")
@PreAuthorize("hasRole('STUDENT')")
public class StudentController {

    @Autowired
    private WalletRepository walletRepository;

    @Autowired
    private MealRepository mealRepository;

    @Autowired
    private TokenRepository tokenRepository;

    @Autowired
    private CoinTransactionRepository coinTransactionRepository;

    @Autowired
    private MarketplaceRepository marketplaceRepository;

    /**
     * GET /students/wallet — Get the authenticated student's wallet balance.
     */
    @GetMapping("/wallet")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getMyWallet(
            @AuthenticationPrincipal User currentUser) {
        Wallet wallet = walletRepository.findByUserId(currentUser.getId())
                .orElse(null);
        BigDecimal balance = wallet != null ? wallet.getBalance() : BigDecimal.ZERO;

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("userId", currentUser.getId());
        data.put("balance", balance);

        return ResponseEntity.ok(new ApiResponse<>("Wallet balance retrieved", data));
    }

    /**
     * GET /students/meals/today — Today's meals for the student's hall.
     * Returns meal configs (menu, price, type) for today.
     */
    @GetMapping("/meals/today")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getTodayMeals(
            @AuthenticationPrincipal User currentUser) {
        Long hallId = currentUser.getHall() != null ? currentUser.getHall().getId() : null;
        if (hallId == null) {
            return ResponseEntity.ok(new ApiResponse<>("No hall assigned", List.of()));
        }

        LocalDate today = LocalDate.now();
        List<Meal> meals = mealRepository.findByHallIdAndMealDate(hallId, today);

        List<Map<String, Object>> result = meals.stream().map(m -> {
            Map<String, Object> map = new LinkedHashMap<>();
            map.put("mealId", m.getId());
            map.put("mealType", m.getMealType().name());
            map.put("mealDate", m.getMealDate().toString());
            map.put("menu", m.getMenu());
            map.put("price", m.getPrice());
            map.put("purchaseDeadline", m.getPurchaseDeadline() != null ? m.getPurchaseDeadline().toString() : null);
            map.put("isClosed", m.getIsClosed());
            map.put("canPurchase", !m.getIsClosed() &&
                    (m.getPurchaseDeadline() == null || LocalDateTime.now().isBefore(m.getPurchaseDeadline())));
            return map;
        }).collect(Collectors.toList());

        return ResponseEntity.ok(new ApiResponse<>("Today's meals", result));
    }

    /**
     * GET /students/meals/available — Meals available for purchase (today + tomorrow).
     * Only meals where purchase deadline hasn't passed and meal is not closed.
     */
    @GetMapping("/meals/available")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getAvailableMeals(
            @AuthenticationPrincipal User currentUser) {
        Long hallId = currentUser.getHall() != null ? currentUser.getHall().getId() : null;
        if (hallId == null) {
            return ResponseEntity.ok(new ApiResponse<>("No hall assigned", List.of()));
        }

        LocalDate today = LocalDate.now();
        LocalDate tomorrow = today.plusDays(1);
        List<Meal> meals = mealRepository.findByHallIdAndMealDateBetweenOrderByMealDateDesc(hallId, today, tomorrow);

        LocalDateTime now = LocalDateTime.now();
        List<Map<String, Object>> result = meals.stream()
                .filter(m -> !m.getIsClosed())
                .filter(m -> m.getPurchaseDeadline() == null || now.isBefore(m.getPurchaseDeadline()))
                .map(m -> {
                    Map<String, Object> map = new LinkedHashMap<>();
                    map.put("mealId", m.getId());
                    map.put("mealType", m.getMealType().name());
                    map.put("mealDate", m.getMealDate().toString());
                    map.put("menu", m.getMenu());
                    map.put("price", m.getPrice());
                    map.put("purchaseDeadline", m.getPurchaseDeadline() != null ? m.getPurchaseDeadline().toString() : null);
                    return map;
                }).collect(Collectors.toList());

        return ResponseEntity.ok(new ApiResponse<>("Available meals for purchase", result));
    }

    /**
     * GET /students/history — Aggregated transaction history for the student.
     * Combines: token purchases, wallet top-ups, marketplace activity, token usage.
     */
    @GetMapping("/history")
    public ResponseEntity<ApiResponse<List<TransactionHistoryResponse>>> getTransactionHistory(
            @AuthenticationPrincipal User currentUser) {

        Long userId = currentUser.getId();
        List<TransactionHistoryResponse> history = new ArrayList<>();

        // 1. Token purchases
        List<Token> tokens = tokenRepository.findByOwnerOrderByCreatedAtDesc(currentUser);
        for (Token t : tokens) {
            Meal meal = t.getMeal();
            String mealType = meal.getMealType().name();
            String mealDate = meal.getMealDate().toString();
            BigDecimal price = meal.getPrice();

            // Purchase entry
            history.add(TransactionHistoryResponse.builder()
                    .type("PURCHASE")
                    .description(mealType.substring(0, 1) + mealType.substring(1).toLowerCase() + " token purchased")
                    .amount(-price.doubleValue())
                    .mealType(mealType)
                    .mealDate(mealDate)
                    .paymentMethod("wallet")
                    .status("completed")
                    .timestamp(t.getCreatedAt())
                    .build());

            // Used entry
            if (t.getUsedAt() != null) {
                history.add(TransactionHistoryResponse.builder()
                        .type("USED")
                        .description(mealType.substring(0, 1) + mealType.substring(1).toLowerCase() + " token used")
                        .amount(0)
                        .mealType(mealType)
                        .mealDate(mealDate)
                        .paymentMethod("")
                        .status("completed")
                        .timestamp(t.getUsedAt())
                        .build());
            }
        }

        // 2. Wallet top-ups (CoinTransaction where receiver = student)
        List<CoinTransaction> coinTxns = coinTransactionRepository.findBySenderIdOrReceiverId(userId, userId);
        for (CoinTransaction ct : coinTxns) {
            if (ct.getType() == TransactionType.TOPUP && ct.getReceiver() != null
                    && ct.getReceiver().getId().equals(userId)) {
                history.add(TransactionHistoryResponse.builder()
                        .type("TOPUP")
                        .description("Wallet credited ৳" + ct.getAmount())
                        .amount(ct.getAmount().doubleValue())
                        .mealType("")
                        .mealDate("")
                        .paymentMethod("cash")
                        .status("completed")
                        .timestamp(ct.getCreatedAt())
                        .build());
            }
        }

        // 3. Marketplace activity
        try {
            List<MarketplacePost> posts = marketplaceRepository.findBySellerIdOrBuyerId(userId);
            for (MarketplacePost mp : posts) {
                Meal meal = mp.getToken().getMeal();
                String mealType = meal.getMealType().name();
                String mealDate = meal.getMealDate().toString();
                BigDecimal price = meal.getPrice();
                String postStatus = mp.getStatus().name().toLowerCase();

                if (mp.getSeller().getId().equals(userId)) {
                    // Student sold a token
                    String desc = "Sold " + mealType.substring(0, 1) + mealType.substring(1).toLowerCase() + " token";
                    if (mp.getStatus().name().equals("COMPLETED")) {
                        desc += " (completed)";
                    }
                    history.add(TransactionHistoryResponse.builder()
                            .type("MARKETPLACE_SELL")
                            .description(desc)
                            .amount(mp.getStatus().name().equals("COMPLETED") ? price.doubleValue() : 0)
                            .mealType(mealType)
                            .mealDate(mealDate)
                            .paymentMethod(mp.getPaymentType() != null ? mp.getPaymentType().name().toLowerCase() : "")
                            .status(postStatus)
                            .timestamp(mp.getCreatedAt())
                            .build());
                }
                if (mp.getBuyer() != null && mp.getBuyer().getId().equals(userId)) {
                    // Student bought a token
                    String desc = "Bought " + mealType.substring(0, 1) + mealType.substring(1).toLowerCase() + " token from marketplace";
                    history.add(TransactionHistoryResponse.builder()
                            .type("MARKETPLACE_BUY")
                            .description(desc)
                            .amount(-price.doubleValue())
                            .mealType(mealType)
                            .mealDate(mealDate)
                            .paymentMethod(mp.getPaymentType() != null ? mp.getPaymentType().name().toLowerCase() : "")
                            .status(postStatus)
                            .timestamp(mp.getBuyerRequestedAt() != null ? mp.getBuyerRequestedAt() : mp.getCreatedAt())
                            .build());
                }
            }
        } catch (Exception e) {
            // Marketplace data is optional — don't fail the whole history
        }

        // Sort by timestamp descending
        history.sort((a, b) -> b.getTimestamp().compareTo(a.getTimestamp()));

        return ResponseEntity.ok(new ApiResponse<>("Transaction history", history));
    }
}
