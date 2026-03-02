package dsi.ruet.backend.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "halls")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Hall {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String name;
}
