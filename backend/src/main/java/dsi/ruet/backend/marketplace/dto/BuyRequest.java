package dsi.ruet.backend.marketplace.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BuyRequest {
    private Long postId;
    private String paymentType;  // "TRANSACTION" or "TOPUP"
}
