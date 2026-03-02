package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Response DTO for student wallet balance lookup.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentBalanceResponse {
    private Long studentId;
    private String studentName;
    private BigDecimal balance;
}
