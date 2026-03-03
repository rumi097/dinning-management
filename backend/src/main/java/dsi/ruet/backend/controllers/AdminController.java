package dsi.ruet.backend.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import dsi.ruet.backend.dto.ApiResponse;
import dsi.ruet.backend.dto.admin.AddUserRequest;
import dsi.ruet.backend.dto.admin.AddHallRequest;
import dsi.ruet.backend.dto.admin.UserResponse;
import dsi.ruet.backend.models.User;
import dsi.ruet.backend.models.Hall;
import dsi.ruet.backend.services.AdminService;
import jakarta.validation.Valid;

import java.util.List;


@RestController
@RequestMapping("/admin")
public class AdminController {

    private final AdminService adminService;

    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    /**
     * Add a new user to the system
     */
    @PostMapping("/add-user")
    public ResponseEntity<ApiResponse<User>> addUser(@Valid @RequestBody AddUserRequest request) {
        ApiResponse<User> response = adminService.addUser(request);
        return ResponseEntity.ok(response);
    }

    /**
     * Get user by email
     */
    @GetMapping("/user")
    public ResponseEntity<ApiResponse<UserResponse>> getUserByEmail(@RequestParam String email) {
        ApiResponse<UserResponse> response = adminService.getUserByEmail(email);
        return ResponseEntity.ok(response);
    }

    /**
     * Get all users
     */
    @GetMapping("/users")
    public ResponseEntity<ApiResponse<List<UserResponse>>> getAllUsers() {
        ApiResponse<List<UserResponse>> response = adminService.getAllUsers();
        return ResponseEntity.ok(response);
    }

    /**
     * Delete user by email
     */
    @DeleteMapping("/user")
    public ResponseEntity<ApiResponse<Void>> deleteUserByEmail(@RequestParam String email) {
        ApiResponse<Void> response = adminService.deleteUserByEmail(email);
        return ResponseEntity.ok(response);
    }

    /**
     * Add a new hall to the system
     */
    @PostMapping("/add-hall")
    public ResponseEntity<ApiResponse<Hall>> addHall(@Valid @RequestBody AddHallRequest request) {
        ApiResponse<Hall> response = adminService.addHall(request);
        return ResponseEntity.ok(response);
    }
}