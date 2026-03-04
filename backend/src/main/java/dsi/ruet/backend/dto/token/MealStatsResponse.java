package dsi.ruet.backend.dto.token;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Response DTO for dining manager dashboard.
 * Shows today's meal statistics: total tokens sold vs already used.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MealStatsResponse {

    private Long mealId;
    private String mealType;
    private LocalDate mealDate;
    private String menu;

    /** Total tokens purchased (sold) for this meal */
    private long totalTokens;

    /** Tokens already used (scanned in) */
    private long usedTokens;

    /** Tokens remaining (not yet scanned) = totalTokens - usedTokens */
    private long remainingTokens;
}
