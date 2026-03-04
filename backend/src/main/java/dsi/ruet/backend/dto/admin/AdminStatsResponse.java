package dsi.ruet.backend.dto.admin;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AdminStatsResponse {
    private long totalUsers;
    private long totalStudents;
    private long totalMealManagers;
    private long totalDiningManagers;
    private long totalHalls;
    private long verifiedUsers;
    private long unverifiedUsers;
    private List<HallSummary> halls;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class HallSummary {
        private Long id;
        private String name;
        private long studentCount;
        private long mealManagerCount;
        private long diningManagerCount;
    }
}
