package dsi.ruet.backend.marketplace;

import dsi.ruet.backend.models.Token;
import dsi.ruet.backend.models.User;
import dsi.ruet.backend.models.enums.MarketplacePostStatus;
import dsi.ruet.backend.models.enums.TransactionType;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "marketplace_posts")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MarketplacePost {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "token_id", nullable = false)
    private Token token;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_id")
    private User buyer;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MarketplacePostStatus status;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "buyer_requested_at")
    private LocalDateTime buyerRequestedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_type")
    private TransactionType paymentType;

    @PrePersist
    protected void onCreate() {
        if (this.createdAt == null) {
            this.createdAt = LocalDateTime.now();
        }
        if (this.status == null) {
            this.status = MarketplacePostStatus.OPEN;
        }
    }
}
