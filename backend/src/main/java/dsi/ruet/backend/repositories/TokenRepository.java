package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.Token;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TokenRepository extends JpaRepository<Token, Long> {
    List<Token> findByMealId(Integer mealId);
    Optional<Token> findByMealIdAndOwnerId(Integer mealId, Long ownerId);
    long countByMealIdAndStatusNot(Integer mealId, String status);
    long countByMealId(Integer mealId);
}
