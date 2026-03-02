package dsi.ruet.backend.controllers;

import dsi.ruet.backend.dto.auth.AuthResponse;
import dsi.ruet.backend.dto.auth.LoginRequest;
import dsi.ruet.backend.dto.auth.SignupRequest;
import dsi.ruet.backend.dto.auth.SignupResponse;
import dsi.ruet.backend.dto.auth.OtpResponse;
import dsi.ruet.backend.dto.auth.OtpVerificationResponse;
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
     * Student signup endpoint (step 3 of signup process)
     * Requirements:
     * 1. Email must already exist in Users table (created by admin as placeholder)
     * 2. Email must be verified via OTP (call /send-otp and /verify-otp first)
     * 3. Student provides: email, password, name, roll, phoneNo, roomNo (optional), hallId (optional)
     * 4. After successful signup, user is marked as verified and can login
     * 
     * Flow:
     * 1. User calls /send-otp with email
     * 2. User calls /verify-otp with email and OTP
     * 3. User calls /signup with full signup details (email must be pre-verified via OTP)
     */
    @PostMapping("/signup")
    public ResponseEntity<SignupResponse> signup(@RequestBody SignupRequest request) {
        SignupResponse response = authenticationService.signup(request);
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
     * Send OTP endpoint (step 1 of signup process)
     * Frontend calls this when user clicks "Sign Up"
     * This endpoint:
     * 1. Accepts user email
     * 2. Generates OTP (fixed 123456 for testing)
     * 3. Stores email-OTP pair temporarily
     * 4. Returns success response
     * Note: Actually sending OTP to email is not implemented yet
     */
    @PostMapping("/send-otp")
    public ResponseEntity<OtpResponse> sendOtp(@RequestParam String email) {
        OtpResponse response = authenticationService.sendOtp(email);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    /**
     * Verify OTP endpoint (step 2 of signup process)
     * Frontend calls this when user enters OTP and clicks "Verify"
     * This endpoint:
     * 1. Accepts email and OTP code from frontend
     * 2. Validates OTP against stored OTP in cache
     * 3. Marks email as verified (prerequisite for signup)
     * 4. Returns success/failure response (no token yet)
     */
    @PostMapping("/verify-otp")
    public ResponseEntity<OtpVerificationResponse> verifyOtp(@RequestParam String email, @RequestParam String otp) {
        OtpVerificationResponse response = authenticationService.verifyOtp(email, otp);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
}
