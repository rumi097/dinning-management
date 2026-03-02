package dsi.ruet.backend.models;

import dsi.ruet.backend.models.enums.Role;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(name = "pass")
    private String password;

    @Column(nullable = false)
    private String name;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hall_id", nullable = false)
    private Hall hall;

    @Column(name = "is_verified", nullable = false)
    private Boolean isVerified = false;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;
}
