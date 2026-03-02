package dsi.ruet.backend.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "meals", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"hall_id", "meal_date", "meal_type"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Meal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hall_id", nullable = false)
    private Hall hall;

    @Column(name = "meal_date", nullable = false)
    private LocalDate mealDate;

    @Column(name = "meal_type", nullable = false, length = 10)
    private String mealType; // Lunch, Dinner, etc.

    @Column(name = "menu", columnDefinition = "TEXT")
    private String menu;

    @Column(name = "purchase_start_time", nullable = false)
    private LocalDateTime purchaseStartTime;

    @Column(name = "purchase_end_time", nullable = false)
    private LocalDateTime purchaseEndTime;

    @Column(name = "price", nullable = false)
    private Float price;

    @Column(name = "is_closed", nullable = false)
    private Boolean isClosed = false;

    // Timestamp when refunds were processed for this meal (null = not yet refunded)
    @Column(name = "refunded_at")
    private java.time.LocalDateTime refundedAt;
}
