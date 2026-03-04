package dsi.ruet.backend.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Entity
@Table(name = "wallets")
@Data
@NoArgsConstructor
public class Wallet {

    @Id
    @Column(name = "id")
    private Long userId;

    @Column(precision = 10, scale = 2, nullable = false)
    private BigDecimal balance = BigDecimal.ZERO;

    /** Convenience: set userId (PK) from a User object. */
    public void setUser(User user) {
        if (user != null) {
            this.userId = user.getId();
        }
    }

    /** Deduct amount from balance */
    public void deduct(BigDecimal amount) {
        this.balance = this.balance.subtract(amount);
    }

    /** Deduct amount (Long) from balance */
    public void deduct(Long amount) {
        this.balance = this.balance.subtract(BigDecimal.valueOf(amount));
    }

    /** Credit amount to balance */
    public void credit(BigDecimal amount) {
        this.balance = this.balance.add(amount);
    }

    /** Credit amount (Long) to balance */
    public void credit(Long amount) {
        this.balance = this.balance.add(BigDecimal.valueOf(amount));
    }
}
