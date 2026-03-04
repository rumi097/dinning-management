package dsi.ruet.backend.dto.mealmanager;

import com.fasterxml.jackson.annotation.JsonProperty;
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

    @JsonProperty("isLunchAvailable")
    private boolean isLunchAvailable;  // false = close lunch

    @JsonProperty("isDinnerAvailable")
    private boolean isDinnerAvailable; // false = close dinner
}
