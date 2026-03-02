package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repository for User entity.
 * Provides lookup by email and hall-based counts.
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);

    /** Count all students in a specific hall */
    long countByHallIdAndRole(Long hallId, String role);
}
