package dsi.ruet.backend.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "wallets")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Wallet {

    @Id
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "id")
    private User user;

    @Column(nullable = false)
    private Double balance = 0.0;

    public void deduct(double amount) {
        if (this.balance < amount) {
            throw new IllegalStateException("Insufficient balance");
        }
        this.balance -= amount;
    }

    public void credit(double amount) {
        this.balance += amount;
    }
}
