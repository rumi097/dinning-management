package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.User;
import dsi.ruet.backend.models.enums.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
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

    /** Count all users with a specific role in a specific hall */
    @Query("SELECT COUNT(u) FROM User u WHERE u.hall.id = :hallId AND u.role = :role")
    long countByHallIdAndRole(@Param("hallId") Long hallId, @Param("role") Role role);
}
