package dsi.ruet.backend.services;

import dsi.ruet.backend.dto.SignupRequest;
import dsi.ruet.backend.dto.LoginRequest;
import dsi.ruet.backend.dto.AuthResponse;
import dsi.ruet.backend.exception.DuplicateEmailException;
import dsi.ruet.backend.exception.AuthenticationException;
import dsi.ruet.backend.exception.ResourceNotFoundException;
import dsi.ruet.backend.models.AuthUser;
import dsi.ruet.backend.models.Student;
import dsi.ruet.backend.models.Wallet;
import dsi.ruet.backend.models.Hall;
import dsi.ruet.backend.repositories.AuthUserRepository;
import dsi.ruet.backend.repositories.StudentRepository;
import dsi.ruet.backend.repositories.WalletRepository;
import dsi.ruet.backend.repositories.HallRepository;
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
    private AuthUserRepository authUserRepository;

    @Autowired
    private StudentRepository studentRepository;

    @Autowired
    private WalletRepository walletRepository;

    @Autowired
    private HallRepository hallRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenProvider tokenProvider;

    @Transactional
    public AuthResponse signup(SignupRequest request) {
        // Check if email already exists
        if (authUserRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException("Email already registered: " + request.getEmail());
        }

        // Create auth user
        AuthUser authUser = new AuthUser();
        authUser.setEmail(request.getEmail());
        authUser.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        authUser.setRole(request.getRole() != null ? request.getRole() : "STUDENT");
        authUser.setIsVerified(true); // For now, auto-verify. In production, use OTP
        authUser = authUserRepository.save(authUser);

        // If student role, create student profile
        if ("STUDENT".equals(authUser.getRole())) {
            Student student = new Student();
            student.setAuthUser(authUser);
            student.setName(request.getName());
            student.setRoll(request.getRoll());
            student.setPhone(request.getPhone());
            student.setRoomNo(request.getRoomNo());

            // Set hall if provided
            if (request.getHallId() != null) {
                Hall hall = hallRepository.findById(request.getHallId())
                        .orElseThrow(() -> new ResourceNotFoundException("Hall not found"));
                student.setHall(hall);
            }

            student = studentRepository.save(student);

            // Create wallet for student
            Wallet wallet = new Wallet();
            wallet.setStudent(student);
            wallet.setBalance(java.math.BigDecimal.ZERO);
            walletRepository.save(wallet);
        }

        // Generate token
        String token = tokenProvider.generateTokenFromEmail(authUser.getEmail(), authUser.getRole());

        AuthResponse response = new AuthResponse();
        response.setToken(token);
        response.setEmail(authUser.getEmail());
        response.setRole(authUser.getRole());
        response.setUserId(authUser.getId());

        // Set name if available
        if ("STUDENT".equals(authUser.getRole())) {
            Student student = studentRepository.findByAuthUserId(authUser.getId())
                    .orElse(null);
            if (student != null) {
                response.setName(student.getName());
            }
        }

        return response;
    }

    public AuthResponse login(LoginRequest request) {
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

        AuthUser authUser = authUserRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        AuthResponse response = new AuthResponse();
        response.setToken(token);
        response.setEmail(authUser.getEmail());
        response.setRole(authUser.getRole());
        response.setUserId(authUser.getId());

        // Set name if available
        if ("STUDENT".equals(authUser.getRole())) {
            Student student = studentRepository.findByAuthUserId(authUser.getId())
                    .orElse(null);
            if (student != null) {
                response.setName(student.getName());
            }
        }

        return response;
    }

    public AuthUser getCurrentUser(String email) {
        return authUserRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }
}
