package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SetMenuRequest {
    private String mealType;              // LUNCH or DINNER
    private String menu;                  // menu text
    private java.math.BigDecimal price;   // meal price
    private LocalDateTime purchaseStartTime;
    private LocalDateTime purchaseEndTime;
}
