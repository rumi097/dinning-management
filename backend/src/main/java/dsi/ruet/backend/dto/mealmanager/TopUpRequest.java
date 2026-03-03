package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Request body for wallet top-up.
 * studentId is the student's roll number (String), e.g. "S2021001".
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TopUpRequest {
    private String studentId;     // student roll number (matches frontend)
    private BigDecimal amount;    // amount to add (1 credit = 1 BDT)
}
