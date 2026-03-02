package dsi.ruet.backend.dto.manager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SalesReportResponse {
    private String date;
    private Long hallId;
    private List<MealSalesDetail> meals;
    private long totalTokensSold;
    private BigDecimal totalRevenue;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MealSalesDetail {
        private Long mealId;
        private String mealType;
        private String menu;
        private BigDecimal price;
        private long tokensSold;
        private long tokensUsed;
        private long tokensActive;
        private BigDecimal revenue;
    }
}
