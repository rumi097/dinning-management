package dsi.ruet.backend.dto.manager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SalesSummaryResponse {
    private Long hallId;

    // Today's stats
    private String todayDate;
    private long todayLunchTokensSold;
    private long todayDinnerTokensSold;
    private BigDecimal todayRevenue;

    // Tomorrow's stats (configured meals)
    private String tomorrowDate;
    private long tomorrowLunchTokensSold;
    private long tomorrowDinnerTokensSold;
    private BigDecimal tomorrowRevenue;

    // Meal configs for tomorrow
    private List<MealConfigSummary> tomorrowMealConfigs;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MealConfigSummary {
        private Long mealId;
        private String mealType;
        private String menu;
        private BigDecimal price;
        private String purchaseDeadline;
        private long tokensSold;
    }
}
