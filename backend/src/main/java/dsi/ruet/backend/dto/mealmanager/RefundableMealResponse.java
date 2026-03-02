package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Response DTO for a cancelled meal that is eligible for refund
 * or has already been refunded.
 * Maps to the Flutter RefundableMeal model.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RefundableMealResponse {
    private String id;                          // meal ID as string
    private String date;                        // YYYY-MM-DD
    private String mealType;                    // LUNCH or DINNER
    private int tokensSold;                     // how many tokens were sold
    private double pricePerToken;               // meal price
    private double totalRefundAmount;           // tokensSold * pricePerToken
    private List<StudentTokenResponse> students;// students who hold tokens
    private String status;                      // PENDING or COMPLETED
    private String refundedAt;                  // timestamp when refund was processed (null if pending)
}
