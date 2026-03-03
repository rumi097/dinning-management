package dsi.ruet.backend.common.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TokenResponse {
    private Long id;
    private Long mealId;
    private String mealType;
    private String mealDate;
    private String menu;
    private Long price;
    private String status;
}
