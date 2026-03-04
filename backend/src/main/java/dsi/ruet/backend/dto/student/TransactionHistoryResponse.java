package dsi.ruet.backend.dto.student;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO for a unified transaction history entry shown to students.
 * Covers: token purchases, wallet top-ups, marketplace sells/buys, refunds.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransactionHistoryResponse {

    /** Type of transaction: PURCHASE, TOPUP, MARKETPLACE_SELL, MARKETPLACE_BUY, REFUND, USED */
    private String type;

    /** Human-readable description */
    private String description;

    /** Amount (positive for credits, negative for debits) */
    private double amount;

    /** Meal type if applicable (LUNCH / DINNER) */
    private String mealType;

    /** Meal date if applicable */
    private String mealDate;

    /** Payment method: wallet, cash, credit, etc. */
    private String paymentMethod;

    /** Status: completed, pending, cancelled */
    private String status;

    /** When this transaction occurred */
    private LocalDateTime timestamp;
}
