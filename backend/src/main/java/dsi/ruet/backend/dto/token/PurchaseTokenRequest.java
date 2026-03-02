package dsi.ruet.backend.dto.token;

// Jakarta validation annotation for enforcing non-null constraints
import jakarta.validation.constraints.NotNull;
// Lombok annotations for boilerplate code generation
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for purchasing a meal token.
 * The student specifies which meal they want to buy a token for;
 * the system then validates the deadline, checks wallet balance,
 * and creates the token.
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PurchaseTokenRequest {

    /** ID of the meal to purchase a token for (must not be null) */
    @NotNull(message = "Meal ID is required")
    private Long mealId;
}
