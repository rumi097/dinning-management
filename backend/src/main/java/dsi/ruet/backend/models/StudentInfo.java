package dsi.ruet.backend.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "student_infos")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentInfo {

    @Id
    private Long id;

    // Shared primary key with users table
    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "id")
    private User user;

    @Column(unique = true, nullable = false, length = 50)
    private String roll;

    @Column(name = "room_no", length = 20)
    private String roomNo;

    @Column(name = "phone_no", nullable = false, length = 20)
    private String phoneNo;
}
