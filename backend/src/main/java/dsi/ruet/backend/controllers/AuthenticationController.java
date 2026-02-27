package dsi.ruet.backend.controllers;

import dsi.ruet.backend.dto.auth.AuthResponse;
import dsi.ruet.backend.dto.auth.LoginRequest;
import dsi.ruet.backend.dto.auth.SignupRequest;
import dsi.ruet.backend.services.AuthenticationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthenticationController {

    @Autowired
    private AuthenticationService authenticationService;

    /**
     * Student signup endpoint
     * Requirements:
     * 1. Email must already exist in Users table (created by admin as placeholder)
     * 2. User must not be verified yet
     * 3. Student provides: password, name, roll, phoneNo, roomNo (optional), hallId (optional)
     * 4. After signup, OTP will be sent to email for verification
     * 5. TODO: Implement OTP verification endpoint
     */
    @PostMapping("/signup")
    public ResponseEntity<AuthResponse> signup(@RequestBody SignupRequest request) {
        AuthResponse response = authenticationService.signup(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    /**
     * Login endpoint
     * Takes email and password
     * Returns user info with StudentInfo if role is STUDENT
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        AuthResponse response = authenticationService.login(request);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    /**
     * Get current logged in user information
     * Returns user details including StudentInfo if role is STUDENT
     * Requires valid JWT token in Authorization header
     */
    @GetMapping("/me")
    public ResponseEntity<AuthResponse> getCurrentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        String email = authentication.getName();
        AuthResponse response = authenticationService.getCurrentUser(email);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    /**
     * TODO: Verify OTP for email verification after signup
     * This endpoint will:
     * 1. Accept email and OTP code
     * 2. Validate OTP against stored code
     * 3. Mark user as verified (isVerified = true)
     * 4. Return JWT token for login
     */
    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestParam String email, @RequestParam String otp) {
        // TODO: Implement OTP verification logic
        return new ResponseEntity<>("OTP verification not yet implemented", HttpStatus.NOT_IMPLEMENTED);
    }
}
