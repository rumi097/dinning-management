package dsi.ruet.backend.services;

import dsi.ruet.backend.dto.auth.AuthResponse;
import dsi.ruet.backend.dto.auth.LoginRequest;
import dsi.ruet.backend.dto.auth.SignupRequest;
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

    @Transactional
    public AuthResponse signup(SignupRequest request) {

        // Check if email exists in Users table (must be pre-created by admin)
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException(
                    "Email not found in system. Please contact admin to create your account."));

        
        // Check if user is already verified (completed signup before)
        if (user.getIsVerified()) {
            throw new AuthenticationException("This user has already completed signup. Please login.");
        }

        // Update user with signup data (override placeholders) - IN MEMORY ONLY
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());

        // Create student info IN MEMORY ONLY if user role is STUDENT
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

        // TODO: DUMMY OTP VERIFICATION - For testing only
        // In real implementation: Generate OTP, send to email, user calls /verify-otp endpoint
        // For now: Automatically verify user (before saving to DB)
        boolean otpVerified = verifyOTPDummy();
        
        if (!otpVerified) {
            throw new AuthenticationException("OTP verification failed. Please try again.");
        }
        
        // OTP passed - now save to database
        user.setIsVerified(true);
        user = userRepository.save(user);

        // Save StudentInfo only if it was created
        if (studentInfo != null) {
            studentInfoRepository.save(studentInfo);
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
        String token = tokenProvider.generateToken(authentication);


        AuthResponse response = new AuthResponse();
        response.setToken(token);
        response.setEmail(user.getEmail());
        response.setUserId(user.getId());
        response.setName(user.getName());
        response.setRole(user.getRole());
        response.setHallId(user.getHallId()); 


        
        // If student role, include StudentInfo
        if ("STUDENT".equals(user.getRole())) {
            StudentInfo savedStudentInfo = studentInfoRepository.findById(user.getId())
                    .orElse(null);
            if (savedStudentInfo != null) {
                response.setRoll(savedStudentInfo.getRoll());
                response.setPhoneNo(savedStudentInfo.getPhoneNo());
                response.setRoomNo(savedStudentInfo.getRoomNo());
            }
        }

        // #### ADD A NEW WALLET LINKED TO THIS USER ID

        
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

    /**
     * Verify OTP and complete signup - returns JWT token for successful verification
     * @param email User email
     * @param otp OTP code provided by user
     * @return AuthResponse with JWT token (same as login response)
     */
    public AuthResponse verifyOTP(String email, String otp) {

        AuthResponse response = new AuthResponse();

        return response;
    }

    /**
     * Dummy OTP verification - always returns true for testing
     * Will be replaced with actual OTP verification logic later
     * @return always true for now
     */
    private boolean verifyOTPDummy() {
        // TODO: Replace this with actual OTP verification
        // For now, always return true to test other parts of the system
        return true;
    }
}
