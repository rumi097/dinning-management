package dsi.ruet.backend.services;

import dsi.ruet.backend.dto.auth.AuthResponse;
import dsi.ruet.backend.dto.auth.LoginRequest;
import dsi.ruet.backend.dto.auth.SignupRequest;
import dsi.ruet.backend.dto.auth.SignupResponse;
import dsi.ruet.backend.dto.auth.OtpResponse;
import dsi.ruet.backend.dto.auth.OtpVerificationResponse;
import dsi.ruet.backend.exception.AuthenticationException;
import dsi.ruet.backend.exception.ResourceNotFoundException;
import dsi.ruet.backend.models.User;
import dsi.ruet.backend.models.StudentInfo;
import dsi.ruet.backend.repositories.UserRepository;
import dsi.ruet.backend.repositories.StudentInfoRepository;
import dsi.ruet.backend.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
public class AuthenticationService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StudentInfoRepository studentInfoRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenProvider tokenProvider;

    // ==================== IN-MEMORY CACHES FOR OTP FLOW ====================
    // Stores email -> OTP pairs (temporary storage, expires after verification)
    private final Map<String, String> emailOtpCache = new HashMap<>();

    @Transactional
    public SignupResponse signup(SignupRequest request) {
        String email = request.getEmail();
        
        // Check if email exists in Users table (must be pre-created by admin)
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "Email not found in system. Please contact admin to create your account."));
        
        if (!user.getIsVerified()) {

            throw new AuthenticationException(
                "Email not verified. Please verify with OTP first by calling /send-otp and /verify-otp endpoints.");
        }


        
        // Check if user is already verified (completed signup before)

        // Update user with signup data
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());

        // Create student info if user role is STUDENT
        StudentInfo studentInfo = null;
        if ("STUDENT".equals(user.getRole())) {
            // Validate required student fields
            if (request.getRoll() == null || request.getPhoneNo() == null || request.getRoomNo()==null) {
                throw new IllegalArgumentException(
                    "For STUDENT role, roll, roomNo and phoneNo are required");
            }

            studentInfo = new StudentInfo();
            studentInfo.setUser(user);
            studentInfo.setRoll(request.getRoll());
            studentInfo.setRoomNo(request.getRoomNo());
            studentInfo.setPhoneNo(request.getPhoneNo());
        }

        // User is already verified via OTP in previous step, just save with password
        user = userRepository.save(user);

        // Save StudentInfo
        if (studentInfo != null) {
            studentInfoRepository.save(studentInfo);
        }
        
        // Return signup success response
        SignupResponse response = new SignupResponse();
        response.setEmail(user.getEmail());
        response.setUserId(user.getId());
        response.setMessage("Signup completed successfully. You can now login.");
        
        
        return response;
    }


    public AuthResponse login(LoginRequest request) {
        // Check if user exists and is verified
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException(
                    "User not found with email: " + request.getEmail()));

        if (!user.getIsVerified()) {
            throw new AuthenticationException(
                "User account not verified. Please complete signup with OTP verification.");
        }

        // Authenticate user
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        if (!authentication.isAuthenticated()) {
            throw new AuthenticationException("Invalid email or password");
        }

        // Generate token
        String token = tokenProvider.generateToken(authentication);

        // Build response with user info
        AuthResponse response = new AuthResponse();
        response.setToken(token);
        response.setEmail(user.getEmail());
        response.setRole(user.getRole());
        response.setUserId(user.getId());
        response.setName(user.getName());
        response.setHallId(user.getHallId());  // Include for all users

        // If student role, include StudentInfo
        if ("STUDENT".equals(user.getRole())) {
            StudentInfo studentInfo = studentInfoRepository.findById(user.getId())
                    .orElse(null);
            if (studentInfo != null) {
                response.setRoll(studentInfo.getRoll());
                response.setPhoneNo(studentInfo.getPhoneNo());
                response.setRoomNo(studentInfo.getRoomNo());
            }
        }

        return response;
    }

    /**
     * Get current logged in user info based on email from JWT token
     * Returns user info with StudentInfo if role is STUDENT
     */
    public AuthResponse getCurrentUser(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Build response with user info
        AuthResponse response = new AuthResponse();
        response.setEmail(user.getEmail());
        response.setRole(user.getRole());
        response.setUserId(user.getId());
        response.setName(user.getName());
        response.setHallId(user.getHallId());  // Include for all users
        response.setToken(null); // No token in /me endpoint

        // If student role, include StudentInfo
        if ("STUDENT".equals(user.getRole())) {
            StudentInfo studentInfo = studentInfoRepository.findById(user.getId())
                    .orElse(null);
            if (studentInfo != null) {
                response.setRoll(studentInfo.getRoll());
                response.setPhoneNo(studentInfo.getPhoneNo());
                response.setRoomNo(studentInfo.getRoomNo());
            }
        }

        return response;
    }

    // ==================== OTP VERIFICATION (Ready for Implementation) ====================

    /**
     * Send OTP to user's email (step 1 of signup flow)
     * Generates OTP (fixed 123456 for now) and stores email-otp pair temporarily
     * @param email User email
     * @return OtpResponse indicating OTP was sent
     */
    public OtpResponse sendOtp(String email) {
        // TODO: Later - check if email exists in Users table
        
        // For now: Accept any email
        if (email == null || email.isEmpty()) {
            throw new IllegalArgumentException("Email cannot be empty");
        }

        // Generate OTP - Fixed value for testing (123456)
        // TODO: Later replace with: Random rand = new Random(); String otp = String.format("%06d", 100000 + rand.nextInt(900000));
        String otp = "123456";

        // Store email-OTP pair in cache (temporary storage)
        emailOtpCache.put(email, otp);
        
        // TODO: Actually send OTP to email using JavaMailSender
        System.out.println("OTP sent to " + email + ": " + otp); // For testing
        
        OtpResponse response = new OtpResponse();
        response.setEmail(email);
        response.setMessage("OTP sent to your email. Please verify with /verify-otp endpoint.");
        response.setSuccess(true);
        
        return response;
    }

    /**
     * Verify OTP provided by user (step 2 of signup flow)
     * Checks if email-otp pair matches the stored value in cache
     * If verified, sets user.isVerified = true in database (prerequisite for signup)
     * @param email User email
     * @param otp OTP code provided by user
     * @return OtpVerificationResponse indicating if verification was successful
     */
    @Transactional
    public OtpVerificationResponse verifyOtp(String email, String otp) {
        if (email == null || email.isEmpty()) {
            throw new IllegalArgumentException("Email cannot be empty");
        }
        
        if (otp == null || otp.isEmpty()) {
            throw new IllegalArgumentException("OTP cannot be empty");
        }

        // Check if email exists in OTP cache
        if (!emailOtpCache.containsKey(email)) {
            OtpVerificationResponse response = new OtpVerificationResponse();
            response.setEmail(email);
            response.setMessage("No OTP found for this email. Please request a new OTP with /send-otp");
            response.setVerified(false);
            return response;
        }

        // Get stored OTP for this email
        String storedOtp = emailOtpCache.get(email);

        // Verify if provided OTP matches stored OTP
        if (!otp.equals(storedOtp)) {
            OtpVerificationResponse response = new OtpVerificationResponse();
            response.setEmail(email);
            response.setMessage("Invalid OTP. Please try again.");
            response.setVerified(false);
            return response;
        }

        // OTP matches - Mark user as verified in database
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "User not found with email: " + email));
        
        user.setIsVerified(true);
        userRepository.save(user);
        
        // Remove OTP from cache after successful verification (once verified, no need to keep OTP)
        emailOtpCache.remove(email);
        
        OtpVerificationResponse response = new OtpVerificationResponse();
        response.setEmail(email);
        response.setMessage("OTP verified successfully. You can now complete signup with /signup endpoint.");
        response.setVerified(true);
        
        return response;
    }

    /**
     * TODO: Generate OTP code (6 digits random)
     * Store in cache/database with expiry time (5-10 minutes)
     * @param email User email
     * @return Generated OTP code
     */
    private String generateOTP(String email) {
        // TODO: Implementation
        // 1. Generate 6-digit random code
        // 2. Save in OTP cache with expiry
        // 3. Log OTP for testing (remove in production)
        // Example: Random rand = new Random(); int otp = 100000 + rand.nextInt(900000);
        return null;
    }

    /**
     * TODO: Send OTP via email
     * @param email User email
     * @param otp OTP code to send
     */
    private void sendOTPEmail(String email, String otp) {
        // TODO: Implementation using JavaMailSender
        // 1. Create email message
        // 2. Send OTP to user's email address
        // 3. Log success/failure
    }
}