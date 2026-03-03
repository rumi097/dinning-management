package dsi.ruet.backend.models;

import dsi.ruet.backend.models.enums.MealType;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "meals", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"hall_id", "meal_date", "meal_type"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Meal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hall_id", nullable = false)
    private Hall hall;

    @Column(name = "meal_date", nullable = false)
    private LocalDate mealDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "meal_type", nullable = false)
    private MealType mealType;

    @Column(columnDefinition = "TEXT")
    private String menu;

    @Column(nullable = false)
    private Long price;

    @Column(name = "purchase_deadline")
    private LocalDateTime purchaseDeadline;
}
