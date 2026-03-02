package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for revenue report.
 * Shows total lunch/dinner revenue on a given date.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RevenueReportResponse {
    private double lunchRevenue;
    private double dinnerRevenue;
}
