package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.Meal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
<<<<<<< HEAD

@Repository
public interface MealRepository extends JpaRepository<Meal, Long> {
    List<Meal> findByHallIdAndMealDate(Long hallId, LocalDate mealDate);
=======
import java.util.Optional;

@Repository
public interface MealRepository extends JpaRepository<Meal, Long> {

    Optional<Meal> findByHallIdAndMealDateAndMealType(Long hallId, LocalDate mealDate, String mealType);

    List<Meal> findByHallIdAndMealDate(Long hallId, LocalDate mealDate);

>>>>>>> 519aad96173a138aa0de36bcf62195c81caef34b
    List<Meal> findByHallId(Long hallId);
}
