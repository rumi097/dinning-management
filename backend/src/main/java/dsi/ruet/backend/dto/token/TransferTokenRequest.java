package dsi.ruet.backend.dto.token;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for transferring a meal token to another user.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransferTokenRequest {

    /** ID of the token to transfer */
    @NotNull(message = "Token ID is required")
    private Long tokenId;

    /** Email of the user to transfer the token to */
    @NotNull(message = "Receiver email is required")
    private String receiverEmail;
}
