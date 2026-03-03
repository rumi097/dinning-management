package dsi.ruet.backend.common.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserResponse {
    private Long id;
    private String name;
    private String email;
    private Long hallId;
    private String hallName;
    private String role;
}
