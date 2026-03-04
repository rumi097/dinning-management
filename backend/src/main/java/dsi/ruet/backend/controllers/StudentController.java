package dsi.ruet.backend.controllers;

import dsi.ruet.backend.dto.ApiResponse;
import dsi.ruet.backend.models.Meal;
import dsi.ruet.backend.models.User;
import dsi.ruet.backend.models.Wallet;
import dsi.ruet.backend.repositories.MealRepository;
import dsi.ruet.backend.repositories.WalletRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
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
}
