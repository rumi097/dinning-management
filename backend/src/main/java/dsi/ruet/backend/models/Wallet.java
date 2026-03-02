package dsi.ruet.backend.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

<<<<<<< HEAD
/**
 * Entity representing a user's wallet balance.
 * Maps to the {@code wallets} table in the database.
 * Each user has exactly one wallet (shared PK with users).
 */
=======
>>>>>>> 519aad96173a138aa0de36bcf62195c81caef34b
@Entity
@Table(name = "wallets")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Wallet {

    @Id
<<<<<<< HEAD
    private Long id;
=======
    private Long id; // Shared PK with users.id
>>>>>>> 519aad96173a138aa0de36bcf62195c81caef34b

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "id")
    private User user;

<<<<<<< HEAD
    @Column(nullable = false, precision = 10, scale = 2)
=======
    @Column(precision = 10, scale = 2)
>>>>>>> 519aad96173a138aa0de36bcf62195c81caef34b
    private BigDecimal balance = BigDecimal.ZERO;
}
