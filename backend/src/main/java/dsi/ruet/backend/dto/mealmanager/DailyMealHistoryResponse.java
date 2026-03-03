package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Daily meal history entry for the history screen.
 * Shows token counts and prices for a single day.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyMealHistoryResponse {
    private String date;       // "March 1, 2026" format
    private int lunchCount;
    private int dinnerCount;
    private double lunchPrice;
    private double dinnerPrice;
}
