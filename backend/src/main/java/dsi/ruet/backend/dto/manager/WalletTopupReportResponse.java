package dsi.ruet.backend.dto.manager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WalletTopupReportResponse {
    private String date;
    private Long hallId;
    private int totalTopups;
    private BigDecimal totalAmount;
    private List<TopupDetail> topups;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TopupDetail {
        private Long transactionId;
        private Long senderId;       // Meal manager who topped up
        private Long receiverId;     // Student who received
        private String receiverName;
        private String receiverEmail;
        private BigDecimal amount;
        private LocalDateTime createdAt;
    }
}
