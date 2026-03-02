package dsi.ruet.backend.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

<<<<<<< HEAD
/**
 * Entity representing a meal offered by a hall.
 * Maps to the {@code meals} table in the database.
 */
@Entity
@Table(name = "meals")
=======
@Entity
@Table(name = "meals", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"hall_id", "meal_date", "meal_type"})
})
>>>>>>> 519aad96173a138aa0de36bcf62195c81caef34b
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Meal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "hall_id", nullable = false)
    private Long hallId;

    @Column(name = "meal_date", nullable = false)
    private LocalDate mealDate;

    @Column(name = "meal_type", nullable = false, length = 10)
<<<<<<< HEAD
    private String mealType; // BREAKFAST, LUNCH, DINNER

    @Column(columnDefinition = "text")
=======
    private String mealType; // LUNCH, DINNER

    @Column(columnDefinition = "TEXT")
>>>>>>> 519aad96173a138aa0de36bcf62195c81caef34b
    private String menu;

    @Column(nullable = false, precision = 8, scale = 2)
    private BigDecimal price;

    @Column(name = "purchase_deadline", nullable = false)
    private LocalDateTime purchaseDeadline;
}
