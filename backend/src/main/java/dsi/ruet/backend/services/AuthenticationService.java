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
import dsi.ruet.backend.models.Hall;
import dsi.ruet.backend.repositories.UserRepository;
import dsi.ruet.backend.repositories.StudentInfoRepository;
import dsi.ruet.backend.repositories.HallRepository;
import dsi.ruet.backend.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

@Service
public class AuthenticationService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StudentInfoRepository studentInfoRepository;

    @Autowired
    private HallRepository hallRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenProvider tokenProvider;

    @Autowired
    private JavaMailSender mailSender;

    @Value("${app.mail.from}")
    private String mailFrom;

    // ==================== IN-MEMORY CACHES FOR OTP FLOW ====================
    // Stores email -> OTP pairs (temporary storage, expires after verification)
    private final Map<String, OtpEntry> emailOtpCache = new HashMap<>();

    /**
     * Inner class to store OTP with expiry time (5 minutes)
     */
    private static class OtpEntry {
        String otp;
        long expiryTime;

        OtpEntry(String otp, long expiryTime) {
            this.otp = otp;
            this.expiryTime = expiryTime;
        }

        /**
         * Check if OTP has expired
         */
        boolean isExpired() {
            return System.currentTimeMillis() > expiryTime;
        }
    }

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
        
        // Fetch and include hall name if hallId is present
        if (user.getHallId() != null) {
            Hall hall = hallRepository.findById(user.getHallId()).orElse(null);
            if (hall != null) {
                response.setHallName(hall.getName());
            }
        }

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
        
        // Fetch and include hall name if hallId is present
        if (user.getHallId() != null) {
            Hall hall = hallRepository.findById(user.getHallId()).orElse(null);
            if (hall != null) {
                response.setHallName(hall.getName());
            }
        }

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

        // Generate random 6-digit OTP
        String otp = generateOTP(email);

        // Set expiry time to 5 minutes from now
        long expiryTime = System.currentTimeMillis() + (5 * 60 * 1000); // 5 minutes in milliseconds
        
        // Store email-OTP pair in cache with expiry time
        // Note: If email already exists, the new OTP-expiry pair will override the old one
        emailOtpCache.put(email, new OtpEntry(otp, expiryTime));
        
        // Send OTP to email using JavaMailSender
        sendOTPEmail(email, otp);
        
        OtpResponse response = new OtpResponse();
        response.setEmail(email);
        response.setMessage("OTP sent to your email. Please verify with /verify-otp endpoint. OTP expires in 5 minutes.");
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

        // Get stored OTP entry for this email
        OtpEntry otpEntry = emailOtpCache.get(email);

        // Check if OTP has expired (5 minutes timeout)
        if (otpEntry.isExpired()) {
            emailOtpCache.remove(email);
            OtpVerificationResponse response = new OtpVerificationResponse();
            response.setEmail(email);
            response.setMessage("OTP has expired (valid for 5 minutes). Please request a new OTP with /send-otp");
            response.setVerified(false);
            return response;
        }

        // Verify if provided OTP matches stored OTP
        if (!otp.equals(otpEntry.otp)) {
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
     * Generate OTP code (6 digits random)
     * @param email User email
     * @return Generated OTP code
     */
    private String generateOTP(String email) {
        // Generate 6-digit random code (100000 to 999999)
        Random rand = new Random();
        int otpCode = 100000 + rand.nextInt(900000);
        String otp = String.valueOf(otpCode);
        
        // Log OTP for testing (remove in production)
        System.out.println("Generated OTP for " + email + ": " + otp);
        
        return otp;
    }

    /**
     * Send OTP via email using JavaMailSender
     * @param email User email
     * @param otp OTP code to send
     */
    private void sendOTPEmail(String email, String otp) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(email);
            message.setSubject("OTP Verification - Your OTP Code");
            message.setText("Hello,\n\n" +
                    "Your One-Time Password (OTP) for signup verification is: " + otp + "\n\n" +
                    "This OTP is valid for 5 minutes only.\n\n" +
                    "If you did not request this OTP, please ignore this email.\n\n" +
                    "Best regards,\n" +
                    "Your Application Team");
            message.setFrom(mailFrom);
            
            mailSender.send(message);
            System.out.println("OTP email sent successfully to: " + email);
        } catch (Exception e) {
            System.err.println("Failed to send OTP email to " + email + ": " + e.getMessage());
            e.printStackTrace();
        }
    }
}