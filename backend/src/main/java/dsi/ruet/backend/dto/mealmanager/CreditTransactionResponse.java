package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Single credit transaction entry for wallet history.
 * Used in GET /wallet/history?date=
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreditTransactionResponse {
    private String id;
    private String studentId;    // roll number
    private String studentName;
    private BigDecimal amount;
    private LocalDateTime timestamp;
}
