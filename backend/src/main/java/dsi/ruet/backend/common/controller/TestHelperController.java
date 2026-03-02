package dsi.ruet.backend.common.controller;

import dsi.ruet.backend.common.dto.ApiResponse;
import dsi.ruet.backend.common.dto.TokenResponse;
import dsi.ruet.backend.common.dto.UserResponse;
import dsi.ruet.backend.models.User;
import dsi.ruet.backend.repositories.TokenRepository;
import dsi.ruet.backend.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Temporary test endpoints for marketplace testing.
 * Remove when auth & real feature modules are integrated.
 */
@RestController
@RequestMapping("/api/v1/test")
@RequiredArgsConstructor
public class TestHelperController {

    private final UserRepository userRepository;
    private final TokenRepository tokenRepository;

    /** List all users (for user-selector dropdown in test UI). */
    @GetMapping("/users")
    public ResponseEntity<ApiResponse<List<UserResponse>>> getAllUsers() {
        List<UserResponse> users = userRepository.findAll().stream()
                .map(u -> UserResponse.builder()
                        .id(u.getId())
                        .name(u.getName())
                        .email(u.getEmail())
                        .hallId(u.getHall().getId())
                        .hallName(u.getHall().getName())
                        .role(u.getRole().name())
                        .build())
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(users));
    }

    /** Get tokens owned by a specific user (for testing token listing). */
    @GetMapping("/tokens")
    public ResponseEntity<ApiResponse<List<TokenResponse>>> getMyTokens(
            @RequestHeader("X-User-Id") Long userId) {
        List<TokenResponse> tokens = tokenRepository.findByOwnerId(userId).stream()
                .map(t -> TokenResponse.builder()
                        .id(t.getId())
                        .mealId(t.getMeal().getId())
                        .mealType(t.getMeal().getMealType().name())
                        .mealDate(t.getMeal().getMealDate().toString())
                        .menu(t.getMeal().getMenu())
                        .price(t.getMeal().getPrice())
                        .status(t.getStatus().name())
                        .build())
                .collect(Collectors.toList());
        return ResponseEntity.ok(ApiResponse.success(tokens));
    }
}
