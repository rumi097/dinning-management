package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for meal availability status.
 * Tells whether lunch/dinner are open or closed for a given date.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MealAvailabilityResponse {
    private String date;              // YYYY-MM-DD
    private boolean isMealAvailable;  // true if at least one meal is open
    private boolean isLunchAvailable; // true if lunch is NOT closed
    private boolean isDinnerAvailable;// true if dinner is NOT closed
}
