package dsi.ruet.backend.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SignupRequest {
    private String email;           // Required - must exist in Users table
    private String password;        // Required - override placeholder
    private String name;            // Required - override placeholder
    private String roll;            // Optional - required only if role is STUDENT
    private String phoneNo;         // Optional - required only if role is STUDENT
    private String roomNo;          // Optional - for STUDENT role
}

