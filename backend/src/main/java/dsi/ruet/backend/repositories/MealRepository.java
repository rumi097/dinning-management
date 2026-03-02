package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.Meal;
import dsi.ruet.backend.models.enums.MealType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface MealRepository extends JpaRepository<Meal, Long> {

    Optional<Meal> findByHallIdAndMealDateAndMealType(Long hallId, LocalDate mealDate, MealType mealType);
}
