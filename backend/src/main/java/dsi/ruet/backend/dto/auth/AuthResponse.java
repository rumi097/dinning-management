package dsi.ruet.backend.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {
    private String token;
    private String email;
    private String role;
    private String name;
    private Long userId;
    private Long hallId;           // For ALL users (from User table)
    private String hallName;       // Hall name (from Hall table)
    
    // StudentInfo fields (only populated for STUDENT role)
    private String roll;           // Student roll number
    private String phoneNo;        // Student phone number
    private String roomNo;         // Student room number
}

