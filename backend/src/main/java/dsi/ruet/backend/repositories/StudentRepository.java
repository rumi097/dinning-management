package dsi.ruet.backend.repositories;

import dsi.ruet.backend.models.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, Long> {
    Optional<Student> findByAuthUserId(Long authUserId);
    Optional<Student> findByRoll(String roll);
}
