package dsi.ruet.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SignupRequest {
    private String email;
    private String password;
    private String name;
    private String roll;
    private String role; // STUDENT, MEAL_MANAGER, DINING_MANAGER
    private Long hallId;
    private String roomNo;
    private String phone;
}
