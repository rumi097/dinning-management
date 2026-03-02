package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.Token;
import dsi.ruet.backend.models.enums.TokenStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TokenRepository extends JpaRepository<Token, Long> {

    /** Get all tokens owned by a user. */
    List<Token> findByOwnerId(Long ownerId);

    /** Get tokens owned by a user with a specific status. */
    List<Token> findByOwnerIdAndStatus(Long ownerId, TokenStatus status);

    /** Check if a user already owns a token for a specific meal (enforces 1 token per meal per student). */
    boolean existsByOwnerIdAndMealId(Long ownerId, Long mealId);
}
