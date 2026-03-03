package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.Meal;
import dsi.ruet.backend.models.enums.MealType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Repository for Meal (meal_config) entity.
 * Provides lookups by hall, date, and meal type.
 */
@Repository
public interface MealRepository extends JpaRepository<Meal, Long> {

    /** All meals for a hall on a specific date */
    List<Meal> findByHallIdAndMealDate(Long hallId, LocalDate mealDate);

    /** Single meal for hall + date + type (unique combo) - with enum */
    Optional<Meal> findByHallIdAndMealDateAndMealType(Long hallId, LocalDate mealDate, MealType mealType);

    /** All meals for a hall */
    List<Meal> findByHallId(Long hallId);

    /** All meals for a hall within a date range (for history) */
    List<Meal> findByHallIdAndMealDateBetweenOrderByMealDateDesc(
            Long hallId, LocalDate startDate, LocalDate endDate);

    /** Find all closed meals for a hall that have NOT been refunded yet (pending) */
    List<Meal> findByHallIdAndIsClosedTrueAndRefundedAtIsNull(Long hallId);

    /** Find all closed meals for a hall that HAVE been refunded (completed) */
    List<Meal> findByHallIdAndIsClosedTrueAndRefundedAtIsNotNullOrderByRefundedAtDesc(Long hallId);

    /** Count closed meals with pending refunds for a hall */
    long countByHallIdAndIsClosedTrueAndRefundedAtIsNull(Long hallId);

    /** Count closed meals with completed refunds for a hall */
    long countByHallIdAndIsClosedTrueAndRefundedAtIsNotNull(Long hallId);
}
