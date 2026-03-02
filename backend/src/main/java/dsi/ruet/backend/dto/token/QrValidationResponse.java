package dsi.ruet.backend.dto.token;

// Lombok annotations for boilerplate code generation
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Response DTO returned after a dining manager scans and validates a QR code.
 * Contains the validation result along with token and meal details so
 * the manager can confirm the token holder's identity before serving.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QrValidationResponse {

    /** Whether the QR code represents a valid, usable token */
    private boolean valid;

    /** The ID of the validated token (null if format is invalid) */
    private Long tokenId;

    /** Name of the token owner for identity verification by the manager */
    private String ownerName;

    /** Type of meal (e.g., "LUNCH", "DINNER") */
    private String mealType;

    /** Date the meal is scheduled for */
    private LocalDate mealDate;

    /** Current status of the token (ACTIVE, USED, etc.) */
    private String status;

    /** Human-readable message explaining the validation result */
    private String message;
}
