package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for meal config details.
 * Returned when frontend queries tomorrow's or any date's meal config.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MealConfigResponse {
    private Long id;
    private String date;             // YYYY-MM-DD
    private String mealType;         // LUNCH or DINNER
    private java.math.BigDecimal price;
    private String menu;
    private String purchaseDeadline; // HH:mm format for frontend display
    private String purchaseStartTime;
    private String purchaseEndTime;
    private boolean isClosed;
}
