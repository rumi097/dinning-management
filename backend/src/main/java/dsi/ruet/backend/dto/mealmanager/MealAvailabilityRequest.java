package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO to update meal availability (open/close dining).
 * Used by meal manager to close lunch, dinner, or both.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MealAvailabilityRequest {
    private String date;               // YYYY-MM-DD
    private boolean isLunchAvailable;  // false = close lunch
    private boolean isDinnerAvailable; // false = close dinner
}
