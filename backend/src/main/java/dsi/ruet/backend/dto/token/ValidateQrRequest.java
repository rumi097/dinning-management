package dsi.ruet.backend.dto.token;

// Jakarta validation annotation for enforcing non-blank string constraints
import jakarta.validation.constraints.NotBlank;
// Lombok annotations for boilerplate code generation
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for validating a QR code scanned by a dining manager.
 * Contains the raw QR code data string that needs to be parsed and
 * checked against existing tokens in the system.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ValidateQrRequest {

    /** The raw QR code string scanned from the student's token (format: "TOKEN:<id>:<uuid>") */
    @NotBlank(message = "QR code data is required")
    private String qrData;
}
