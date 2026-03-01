package dsi.ruet.backend.dto.admin;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AddUserRequest {
    private Long id;
    private String email;
    private Long hallId;     // optional, can be null if not assigned
    private String role;     // STUDENT, MEAL_MANAGER, DINING_MANAGER
}