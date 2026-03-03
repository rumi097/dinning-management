package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.Token;
import dsi.ruet.backend.models.enums.TokenStatus;
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

    // === Marketplace methods ===
    List<Token> findByOwnerId(Long ownerId);
    List<Token> findByOwnerIdAndStatus(Long ownerId, TokenStatus status);
    boolean existsByOwnerIdAndMealId(Long ownerId, Long mealId);

    // === Meal-manager queries ===
    List<Token> findByMealId(Long mealId);
    Optional<Token> findByMealIdAndOwnerId(Long mealId, Long ownerId);
    long countByMealId(Long mealId);
    List<Token> findByMealIdIn(List<Long> mealIds);

    @Query("SELECT COUNT(t) FROM Token t WHERE t.meal.id IN :mealIds")
    long countByMealIdIn(@Param("mealIds") List<Long> mealIds);

    @Query("SELECT COUNT(t) FROM Token t WHERE t.meal.id = :mealId AND t.status = :status")
    long countByMealIdAndStatus(@Param("mealId") Long mealId, @Param("status") TokenStatus status);

    // === Student token service methods ===
    List<Token> findByOwnerOrderByCreatedAtDesc(User owner);
    boolean existsByOwnerAndMeal(User owner, Meal meal);
    Optional<Token> findByQrCode(String qrCode);
}
