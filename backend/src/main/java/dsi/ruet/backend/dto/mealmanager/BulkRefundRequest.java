package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Request body for processing refunds for multiple meals at once.
 * POST /api/v1/refunds/process-bulk
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class BulkRefundRequest {
    private List<String> mealIds;  // list of closed meal IDs to refund
}
