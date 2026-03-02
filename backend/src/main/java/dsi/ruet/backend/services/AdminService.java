package dsi.ruet.backend.services;

import dsi.ruet.backend.dto.ApiResponse;
import dsi.ruet.backend.dto.admin.AddUserRequest;
import dsi.ruet.backend.dto.admin.AddHallRequest;
import dsi.ruet.backend.exception.DuplicateEmailException;
import dsi.ruet.backend.exception.ResourceNotFoundException;
import dsi.ruet.backend.models.User;
import dsi.ruet.backend.models.StudentInfo;
import dsi.ruet.backend.models.Hall;
import dsi.ruet.backend.repositories.UserRepository;
import dsi.ruet.backend.repositories.StudentInfoRepository;
import dsi.ruet.backend.repositories.HallRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AdminService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StudentInfoRepository studentInfoRepository;

    @Autowired
    private HallRepository hallRepository;
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
    

    public ApiResponse<List<User>> getAllUsers() {
        List<User> users = userRepository.findAll();
        return new ApiResponse<>("All users retrieved successfully", users);
    }
    
    public ApiResponse<User> getUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
        return new ApiResponse<>("User retrieved successfully", user);
    }



    @Transactional
    public ApiResponse<Void> deleteUserByEmail(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));
        
        // Delete StudentInfo first (if exists) to avoid foreign key constraint violation
        StudentInfo studentInfo = studentInfoRepository.findById(user.getId()).orElse(null);
        if (studentInfo != null) {
            studentInfoRepository.delete(studentInfo);
        }
        
        // Then delete the user
        userRepository.delete(user);
        return new ApiResponse<>("User deleted successfully", null);
    }

    /**
     * Add a new hall to the system
     */
    @Transactional
    public ApiResponse<Hall> addHall(AddHallRequest request) {
        // Check if hall with same name already exists
        if (hallRepository.findByName(request.getName()).isPresent()) {
            throw new IllegalArgumentException("Hall with name '" + request.getName() + "' already exists");
        }

        // Create new hall
        Hall hall = new Hall();
        hall.setName(request.getName());
        
        // Save and return
        Hall savedHall = hallRepository.save(hall);
        return new ApiResponse<>("Hall added successfully", savedHall);
    }
}
