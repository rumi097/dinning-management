package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TokenSummaryResponse {
    private Long mealId;
    private String mealType;
    private String mealDate;
    private long totalTokensBought;
    private boolean isClosed;
}
