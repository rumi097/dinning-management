package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Aggregated dashboard data returned for the meal manager home screen.
 * Contains today's token sales, revenue, and availability status.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardResponse {
    private int lunchCount;          // tokens sold for today's lunch
    private int dinnerCount;         // tokens sold for today's dinner
    private double lunchRevenue;     // lunchCount * lunchPrice
    private double dinnerRevenue;    // dinnerCount * dinnerPrice
    private int totalStudents;       // total students in this hall
    private int todayTopUps;         // number of top-up transactions today
    private boolean isLunchAvailable;
    private boolean isDinnerAvailable;

    /** Computed field: total meals sold */
    public int getTotalMeals() {
        return lunchCount + dinnerCount;
    }

    /** Computed field: total revenue */
    public double getTotalRevenue() {
        return lunchRevenue + dinnerRevenue;
    }
}
