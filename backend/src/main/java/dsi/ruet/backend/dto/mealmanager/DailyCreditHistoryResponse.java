package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Daily credit (top-up) history entry.
 * Groups all top-up transactions for a single day.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyCreditHistoryResponse {
    private String date;                               // "March 1, 2026"
    private List<CreditTransactionItem> transactions;  // individual top-ups that day

    /**
     * Single credit transaction summary within a day.
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreditTransactionItem {
        private String id;
        private String studentId;    // roll number or user id
        private String studentName;
        private double amount;
        private String time;         // "10:30 AM" format
    }
}
