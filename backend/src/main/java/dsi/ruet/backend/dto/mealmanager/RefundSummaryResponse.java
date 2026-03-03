package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for refund summary statistics.
 * Maps to the Flutter RefundSummary model.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RefundSummaryResponse {
    private int pendingCount;               // number of closed meals with pending refunds
    private int completedCount;             // number of meals already refunded
    private double totalAmountPending;      // total BDT still to be refunded
    private double totalAmountRefunded;     // total BDT already refunded
}
