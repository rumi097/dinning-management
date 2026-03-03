package dsi.ruet.backend.models;

import dsi.ruet.backend.models.enums.MealType;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
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

    @Column(name = "hall_id", insertable = false, updatable = false)
    private Long hallId;

    @Column(name = "meal_date", nullable = false)
    private LocalDate mealDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "meal_type", nullable = false)
    private MealType mealType;

    @Column(name = "menu", columnDefinition = "TEXT")
    private String menu;

    @Column(name = "purchase_start_time")
    private LocalDateTime purchaseStartTime;

    @Column(name = "purchase_end_time")
    private LocalDateTime purchaseEndTime;

    @Column(name = "purchase_deadline")
    private LocalDateTime purchaseDeadline;

    @Column(name = "price", nullable = false, precision = 8, scale = 2)
    private BigDecimal price;

    @Column(name = "is_closed", nullable = false)
    private Boolean isClosed = false;

    // Timestamp when refunds were processed for this meal (null = not yet refunded)
    @Column(name = "refunded_at")
    private LocalDateTime refundedAt;
}
