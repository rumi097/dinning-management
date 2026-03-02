package dsi.ruet.backend.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "student_infos")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StudentInfo {

    @Id
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "id")
    private User user;

    private String roll;

    @Column(name = "room_no")
    private String roomNo;

    @Column(name = "phone_no")
    private String phoneNo;
}
