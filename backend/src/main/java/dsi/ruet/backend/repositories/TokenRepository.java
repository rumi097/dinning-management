package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.Token;
import dsi.ruet.backend.models.TokenStatus;
import dsi.ruet.backend.models.User;
import dsi.ruet.backend.models.Meal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TokenRepository extends JpaRepository<Token, Long> {

    /** Find all tokens owned by a user, ordered by creation date descending */
    List<Token> findByOwnerOrderByCreatedAtDesc(User owner);

    /** Check if a user already has a token for a specific meal */
    boolean existsByOwnerAndMeal(User owner, Meal meal);

    /** Find a token by its QR code string */
    Optional<Token> findByQrCode(String qrCode);

    List<Token> findByMealId(Long mealId);

    List<Token> findByMealIdIn(List<Long> mealIds);

    long countByMealId(Long mealId);

    @Query("SELECT COUNT(t) FROM Token t WHERE t.meal.id IN :mealIds")
    long countByMealIdIn(@Param("mealIds") List<Long> mealIds);

    @Query("SELECT COUNT(t) FROM Token t WHERE t.meal.id = :mealId AND t.status = :status")
    long countByMealIdAndStatus(@Param("mealId") Long mealId, @Param("status") TokenStatus status);
}
