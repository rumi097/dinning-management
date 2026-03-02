package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.Token;
import dsi.ruet.backend.models.enums.TokenStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TokenRepository extends JpaRepository<Token, Long> {

    List<Token> findByOwnerId(Long ownerId);

    List<Token> findByOwnerIdAndStatus(Long ownerId, TokenStatus status);

    boolean existsByOwnerIdAndMealId(Long ownerId, Long mealId);

    List<Token> findByMealId(Long mealId);

    List<Token> findByMealIdIn(List<Long> mealIds);

    long countByMealId(Long mealId);

    @Query("SELECT COUNT(t) FROM Token t WHERE t.meal.id IN :mealIds")
    long countByMealIdIn(@Param("mealIds") List<Long> mealIds);

    @Query("SELECT COUNT(t) FROM Token t WHERE t.meal.id = :mealId AND t.status = :status")
    long countByMealIdAndStatus(@Param("mealId") Long mealId, @Param("status") TokenStatus status);
}
