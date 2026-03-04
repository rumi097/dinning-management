package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Response DTO for revenue overview with daily breakdown.
 * Supports daily/weekly/monthly period views.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RevenueOverviewResponse {
    private String period;                // "daily", "weekly", "monthly"
    private double totalRevenue;
    private double totalLunchRevenue;
    private double totalDinnerRevenue;
    private int totalMealsSold;
    private int totalLunchSold;
    private int totalDinnerSold;
    private List<DailyRevenue> dailyBreakdown;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DailyRevenue {
        private String date;              // YYYY-MM-DD
        private String displayDate;       // e.g. "Mon, Jun 2"
        private int lunchSold;
        private int dinnerSold;
        private double lunchRevenue;
        private double dinnerRevenue;
        private double totalRevenue;
    }
}
