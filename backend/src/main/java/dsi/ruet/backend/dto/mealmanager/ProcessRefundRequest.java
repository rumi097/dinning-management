package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request body for processing a single meal refund.
 * POST /api/v1/refunds/process
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProcessRefundRequest {
    private String mealId;  // ID of the closed meal to refund
}
