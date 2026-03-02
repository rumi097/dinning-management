package dsi.ruet.backend.dto.token;

// Lombok annotations for boilerplate code generation
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO returned after generating a QR code for a meal token.
 * Contains the token identifier, the raw QR code string, and a
 * Base64-encoded PNG image of the QR code for display in the frontend.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class QrResponse {

    /** The ID of the token this QR code represents */
    private Long tokenId;

    /** The raw QR code string in format "TOKEN:<tokenId>:<uuid>" */
    private String qrCode;
}
