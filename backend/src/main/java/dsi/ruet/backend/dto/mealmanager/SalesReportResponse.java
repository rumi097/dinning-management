package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for sales report.
 * Shows how many lunch/dinner tokens were sold on a given date.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class SalesReportResponse {
    private int lunchSold;
    private int dinnerSold;
}
