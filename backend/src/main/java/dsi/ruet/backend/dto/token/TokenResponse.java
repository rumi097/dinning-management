package dsi.ruet.backend.dto.token;

// Lombok annotations for boilerplate code generation
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Response DTO representing a meal token returned to the client.
 * Combines data from both the Token entity and its associated Meal entity
 * to provide a complete view of the token including meal details.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TokenResponse {

    /** Unique identifier of the token */
    private Long id;

    /** ID of the associated meal */
    private Long mealId;

    /** Type of meal (e.g., "LUNCH", "DINNER") */
    private String mealType;

    /** Date the meal is scheduled for */
    private LocalDate mealDate;

    /** Price of the meal in the system's currency */
    private BigDecimal price;

    /** Description of the meal's menu items */
    private String menu;

    /** Current token status (ACTIVE, USED, LISTED, CANCELLED) */
    private String status;

    /** Name of the current token owner */
    private String ownerName;

    /** Timestamp when the token was created (purchased) */
    private LocalDateTime createdAt;

    /** Timestamp when the token was used (null if not yet used) */
    private LocalDateTime usedAt;
}
