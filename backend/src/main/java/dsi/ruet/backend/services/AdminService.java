package dsi.ruet.backend.services;

import dsi.ruet.backend.dto.ApiResponse;
import dsi.ruet.backend.dto.admin.AddUserRequest;
import dsi.ruet.backend.exception.DuplicateEmailException;
import dsi.ruet.backend.exception.ResourceNotFoundException;
import dsi.ruet.backend.models.User;
import dsi.ruet.backend.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AdminService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * Add a new user to the system
     */
    @Transactional
    public ApiResponse<User> addUser(AddUserRequest request) {
        // Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException("Email already registered: " + request.getEmail());
        }

        // Create user
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword("CHANGE_THIS");
        user.setName("CHANGE_THIS");
        user.setHallId(request.getHallId());
        user.setIsVerified(false);
        user.setRole(request.getRole() != null ? request.getRole() : "STUDENT");
        
        user = userRepository.save(user);

        return new ApiResponse<>("User added successfully", user);
    }

    /**
     * Get user by email
     */
    public ApiResponse<User> getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
        return new ApiResponse<>("User retrieved successfully", user);
    }

    /**
     * Get all users
     */
    public ApiResponse<List<User>> getAllUsers() {
        List<User> users = userRepository.findAll();
        return new ApiResponse<>("All users retrieved successfully", users);
    }

    /**
     * Delete user by email
     */
    @Transactional
    public ApiResponse<Void> deleteUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
        
        userRepository.delete(user);
        return new ApiResponse<>("User deleted successfully", null);
    }
}
