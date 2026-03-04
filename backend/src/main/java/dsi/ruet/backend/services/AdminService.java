package dsi.ruet.backend.services;

import dsi.ruet.backend.dto.ApiResponse;
import dsi.ruet.backend.dto.admin.AddUserRequest;
import dsi.ruet.backend.dto.admin.AddHallRequest;
import dsi.ruet.backend.dto.admin.AdminLoginRequest;
import dsi.ruet.backend.dto.admin.AdminStatsResponse;
import dsi.ruet.backend.dto.admin.UserResponse;
import dsi.ruet.backend.dto.auth.AuthResponse;
import dsi.ruet.backend.exception.AuthenticationException;
import dsi.ruet.backend.exception.DuplicateEmailException;
import dsi.ruet.backend.exception.ResourceNotFoundException;
import dsi.ruet.backend.models.Hall;
import dsi.ruet.backend.models.User;
import dsi.ruet.backend.models.StudentInfo;
import dsi.ruet.backend.models.enums.Role;
import dsi.ruet.backend.repositories.UserRepository;
import dsi.ruet.backend.repositories.StudentInfoRepository;
import dsi.ruet.backend.repositories.HallRepository;
import dsi.ruet.backend.security.JwtTokenProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class AdminService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StudentInfoRepository studentInfoRepository;

    @Autowired
    private HallRepository hallRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Value("${admin.email}")
    private String adminEmail;

    @Value("${admin.password}")
    private String adminPassword;

    /**
     * Admin login with developer-configured credentials.
     * Returns a JWT token with ADMIN role.
     */
    public AuthResponse adminLogin(AdminLoginRequest request) {
        if (!adminEmail.equals(request.getEmail()) || !adminPassword.equals(request.getPassword())) {
            throw new AuthenticationException("Invalid admin credentials");
        }

        String token = jwtTokenProvider.generateTokenFromEmail(adminEmail, "ADMIN");

        AuthResponse response = new AuthResponse();
        response.setToken(token);
        response.setEmail(adminEmail);
        response.setRole("ADMIN");
        response.setName("System Administrator");
        response.setUserId(0L);
        return response;
    }

    /**
     * Get system-wide statistics for admin dashboard
     */
    public AdminStatsResponse getStats() {
        List<User> allUsers = userRepository.findAll();
        List<Hall> allHalls = hallRepository.findAll();

        long totalStudents = allUsers.stream().filter(u -> u.getRole() == Role.STUDENT).count();
        long totalMealManagers = allUsers.stream().filter(u -> u.getRole() == Role.MEAL_MANAGER).count();
        long totalDiningManagers = allUsers.stream().filter(u -> u.getRole() == Role.DINING_MANAGER).count();
        long verifiedUsers = allUsers.stream().filter(u -> Boolean.TRUE.equals(u.getIsVerified())).count();
        long unverifiedUsers = allUsers.size() - verifiedUsers;

        List<AdminStatsResponse.HallSummary> hallSummaries = new ArrayList<>();
        for (Hall hall : allHalls) {
            hallSummaries.add(AdminStatsResponse.HallSummary.builder()
                    .id(hall.getId())
                    .name(hall.getName())
                    .studentCount(userRepository.countByHallIdAndRole(hall.getId(), Role.STUDENT))
                    .mealManagerCount(userRepository.countByHallIdAndRole(hall.getId(), Role.MEAL_MANAGER))
                    .diningManagerCount(userRepository.countByHallIdAndRole(hall.getId(), Role.DINING_MANAGER))
                    .build());
        }

        return AdminStatsResponse.builder()
                .totalUsers(allUsers.size())
                .totalStudents(totalStudents)
                .totalMealManagers(totalMealManagers)
                .totalDiningManagers(totalDiningManagers)
                .totalHalls(allHalls.size())
                .verifiedUsers(verifiedUsers)
                .unverifiedUsers(unverifiedUsers)
                .halls(hallSummaries)
                .build();
    }

    @Transactional
    public ApiResponse<User> addUser(AddUserRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException("Email already registered: " + request.getEmail());
        }

        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword("CHANGE_THIS");
        user.setName("CHANGE_THIS");
        if (request.getHallId() != null) {
            Hall hall = hallRepository.findById(request.getHallId())
                    .orElseThrow(() -> new ResourceNotFoundException("Hall not found: " + request.getHallId()));
            user.setHall(hall);
        }
        user.setIsVerified(request.getIsVerified() != null ? request.getIsVerified() : false);
        user.setRole(request.getRole() != null ? Role.valueOf(request.getRole()) : Role.STUDENT);

        user = userRepository.save(user);

        return new ApiResponse<>("User added successfully", user);
    }
    

    public ApiResponse<List<UserResponse>> getAllUsers() {
        List<User> users = userRepository.findAll();
        List<UserResponse> result = users.stream().map(user -> {
            StudentInfo info = studentInfoRepository.findById(user.getId()).orElse(null);
            return UserResponse.from(user, info);
        }).toList();
        return new ApiResponse<>("All users retrieved successfully", result);
    }
    
    public ApiResponse<UserResponse> getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
        StudentInfo info = studentInfoRepository.findById(user.getId()).orElse(null);
        return new ApiResponse<>("User retrieved successfully", UserResponse.from(user, info));
    }

    @Transactional
    public ApiResponse<Void> deleteUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));

        StudentInfo studentInfo = studentInfoRepository.findById(user.getId()).orElse(null);
        if (studentInfo != null) {
            studentInfoRepository.delete(studentInfo);
        }

        userRepository.delete(user);
        return new ApiResponse<>("User deleted successfully", null);
    }

    @Transactional
    public ApiResponse<Hall> addHall(AddHallRequest request) {
        if (hallRepository.findByName(request.getName()).isPresent()) {
            throw new IllegalArgumentException("Hall with name '" + request.getName() + "' already exists");
        }

        Hall hall = new Hall();
        hall.setName(request.getName());

        Hall savedHall = hallRepository.save(hall);
        return new ApiResponse<>("Hall added successfully", savedHall);
    }

    public ApiResponse<List<Hall>> getAllHalls() {
        List<Hall> halls = hallRepository.findAll();
        return new ApiResponse<>("All halls retrieved successfully", halls);
    }

    @Transactional
    public ApiResponse<Void> deleteHall(Long hallId) {
        Hall hall = hallRepository.findById(hallId)
                .orElseThrow(() -> new ResourceNotFoundException("Hall not found: " + hallId));
        // Check if any users belong to this hall
        long usersInHall = userRepository.countByHallIdAndRole(hallId, Role.STUDENT)
                + userRepository.countByHallIdAndRole(hallId, Role.MEAL_MANAGER)
                + userRepository.countByHallIdAndRole(hallId, Role.DINING_MANAGER);
        if (usersInHall > 0) {
            throw new IllegalArgumentException("Cannot delete hall with " + usersInHall + " assigned users. Remove users first.");
        }
        hallRepository.delete(hall);
        return new ApiResponse<>("Hall deleted successfully", null);
    }
}
