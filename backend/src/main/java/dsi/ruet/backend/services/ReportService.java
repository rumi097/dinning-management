package dsi.ruet.backend.services;

import dsi.ruet.backend.dto.ApiResponse;
import dsi.ruet.backend.dto.manager.SalesReportResponse;
import dsi.ruet.backend.dto.manager.SalesSummaryResponse;
import dsi.ruet.backend.dto.manager.WalletTopupReportResponse;
import dsi.ruet.backend.exception.ResourceNotFoundException;
import dsi.ruet.backend.models.CoinTransaction;
import dsi.ruet.backend.models.Meal;
import dsi.ruet.backend.models.TokenStatus;
import dsi.ruet.backend.models.User;
import dsi.ruet.backend.repositories.CoinTransactionRepository;
import dsi.ruet.backend.repositories.MealRepository;
import dsi.ruet.backend.repositories.TokenRepository;
import dsi.ruet.backend.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


@Service
public class ReportService {

    @Autowired
    private MealRepository mealRepository;

    @Autowired
    private TokenRepository tokenRepository;

    @Autowired
    private CoinTransactionRepository coinTransactionRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * GET /reports/sales?date=YYYY-MM-DD — Sales report for a given date
     */
    public ApiResponse<SalesReportResponse> getSalesReport(String email, String dateStr) {
        User manager = getManager(email);
        Long hallId = manager.getHallId();
        LocalDate date = LocalDate.parse(dateStr);

        List<Meal> meals = mealRepository.findByHallIdAndMealDate(hallId, date);

        List<SalesReportResponse.MealSalesDetail> details = new ArrayList<>();
        long totalTokens = 0;
        BigDecimal totalRevenue = BigDecimal.ZERO;

        for (Meal meal : meals) {
            long sold = tokenRepository.countByMealId(meal.getId());
            long used = tokenRepository.countByMealIdAndStatus(meal.getId(), TokenStatus.USED);
            long active = tokenRepository.countByMealIdAndStatus(meal.getId(), TokenStatus.AVAILABLE);
            BigDecimal revenue = meal.getPrice().multiply(BigDecimal.valueOf(sold));

            totalTokens += sold;
            totalRevenue = totalRevenue.add(revenue);

            SalesReportResponse.MealSalesDetail detail = new SalesReportResponse.MealSalesDetail();
            detail.setMealId(meal.getId());
            detail.setMealType(meal.getMealType());
            detail.setMenu(meal.getMenu());
            detail.setPrice(meal.getPrice());
            detail.setTokensSold(sold);
            detail.setTokensUsed(used);
            detail.setTokensActive(active);
            detail.setRevenue(revenue);
            details.add(detail);
        }

        SalesReportResponse response = new SalesReportResponse();
        response.setDate(dateStr);
        response.setHallId(hallId);
        response.setMeals(details);
        response.setTotalTokensSold(totalTokens);
        response.setTotalRevenue(totalRevenue);

        return new ApiResponse<>("Sales report for " + dateStr, response);
    }

    /**
     * GET /reports/wallet-topups?date=YYYY-MM-DD — Wallet top-up report for a given date
     */
    public ApiResponse<WalletTopupReportResponse> getWalletTopupReport(String email, String dateStr) {
        User manager = getManager(email);
        Long hallId = manager.getHallId();
        LocalDate date = LocalDate.parse(dateStr);

        // Get all users in this hall
        List<User> hallUsers = userRepository.findAll().stream()
                .filter(u -> hallId.equals(u.getHallId()))
                .collect(Collectors.toList());

        List<Long> hallUserIds = hallUsers.stream()
                .map(User::getId)
                .collect(Collectors.toList());

        // Build a map for quick user lookup
        Map<Long, User> userMap = hallUsers.stream()
                .collect(Collectors.toMap(User::getId, u -> u));

        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();

        List<CoinTransaction> topups = List.of();
        BigDecimal totalAmount = BigDecimal.ZERO;

        if (!hallUserIds.isEmpty()) {
            topups = coinTransactionRepository.findTopUpsByReceiverIdsAndDate(
                    hallUserIds, startOfDay, endOfDay);
            totalAmount = coinTransactionRepository.sumTopUpsByReceiverIdsAndDate(
                    hallUserIds, startOfDay, endOfDay);
        }

        List<WalletTopupReportResponse.TopupDetail> topupDetails = new ArrayList<>();
        for (CoinTransaction tx : topups) {
            WalletTopupReportResponse.TopupDetail detail = new WalletTopupReportResponse.TopupDetail();
            detail.setTransactionId(tx.getId());
            detail.setSenderId(tx.getSenderId());
            detail.setReceiverId(tx.getReceiverId());
            detail.setAmount(tx.getAmount());
            detail.setCreatedAt(tx.getCreatedAt());

            User receiver = userMap.get(tx.getReceiverId());
            if (receiver != null) {
                detail.setReceiverName(receiver.getName());
                detail.setReceiverEmail(receiver.getEmail());
            }
            topupDetails.add(detail);
        }

        WalletTopupReportResponse response = new WalletTopupReportResponse();
        response.setDate(dateStr);
        response.setHallId(hallId);
        response.setTotalTopups(topupDetails.size());
        response.setTotalAmount(totalAmount);
        response.setTopups(topupDetails);

        return new ApiResponse<>("Wallet top-up report for " + dateStr, response);
    }

    /**
     * GET /reports/sales-summary — Get sales summary for today and tomorrow
     */
    public ApiResponse<SalesSummaryResponse> getSalesSummary(String email) {
        User manager = getManager(email);
        Long hallId = manager.getHallId();

        LocalDate today = LocalDate.now();
        LocalDate tomorrow = today.plusDays(1);

        SalesSummaryResponse response = new SalesSummaryResponse();
        response.setHallId(hallId);
        response.setTodayDate(today.toString());
        response.setTomorrowDate(tomorrow.toString());

        // --- Today's stats ---
        List<Meal> todayMeals = mealRepository.findByHallIdAndMealDate(hallId, today);
        long todayLunch = 0, todayDinner = 0;
        BigDecimal todayRevenue = BigDecimal.ZERO;

        for (Meal meal : todayMeals) {
            long count = tokenRepository.countByMealId(meal.getId());
            BigDecimal mealRevenue = meal.getPrice().multiply(BigDecimal.valueOf(count));
            todayRevenue = todayRevenue.add(mealRevenue);

            if ("LUNCH".equals(meal.getMealType())) {
                todayLunch = count;
            } else if ("DINNER".equals(meal.getMealType())) {
                todayDinner = count;
            }
        }
        response.setTodayLunchTokensSold(todayLunch);
        response.setTodayDinnerTokensSold(todayDinner);
        response.setTodayRevenue(todayRevenue);

        // --- Tomorrow's stats ---
        List<Meal> tomorrowMeals = mealRepository.findByHallIdAndMealDate(hallId, tomorrow);
        long tomorrowLunch = 0, tomorrowDinner = 0;
        BigDecimal tomorrowRevenue = BigDecimal.ZERO;
        List<SalesSummaryResponse.MealConfigSummary> configs = new ArrayList<>();

        for (Meal meal : tomorrowMeals) {
            long count = tokenRepository.countByMealId(meal.getId());
            BigDecimal mealRevenue = meal.getPrice().multiply(BigDecimal.valueOf(count));
            tomorrowRevenue = tomorrowRevenue.add(mealRevenue);

            if ("LUNCH".equals(meal.getMealType())) {
                tomorrowLunch = count;
            } else if ("DINNER".equals(meal.getMealType())) {
                tomorrowDinner = count;
            }

            SalesSummaryResponse.MealConfigSummary config = new SalesSummaryResponse.MealConfigSummary();
            config.setMealId(meal.getId());
            config.setMealType(meal.getMealType());
            config.setMenu(meal.getMenu());
            config.setPrice(meal.getPrice());
            config.setPurchaseDeadline(meal.getPurchaseDeadline().toString());
            config.setTokensSold(count);
            configs.add(config);
        }
        response.setTomorrowLunchTokensSold(tomorrowLunch);
        response.setTomorrowDinnerTokensSold(tomorrowDinner);
        response.setTomorrowRevenue(tomorrowRevenue);
        response.setTomorrowMealConfigs(configs);

        return new ApiResponse<>("Sales summary retrieved successfully", response);
    }

    private User getManager(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
        if (!"MEAL_MANAGER".equals(user.getRole())) {
            throw new IllegalStateException("User is not a Meal Manager");
        }
        return user;
    }
}
