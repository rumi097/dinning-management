package dsi.ruet.backend.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "students")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Student {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "auth_user_id", unique = true, nullable = false)
    private AuthUser authUser;

    @Column(nullable = false, length = 120)
    private String name;

    @Column(unique = true, nullable = false, length = 50)
    private String roll;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hall_id")
    private Hall hall;

    @Column(length = 20)
    private String roomNo;

    @Column(length = 20)
    private String phone;
}
