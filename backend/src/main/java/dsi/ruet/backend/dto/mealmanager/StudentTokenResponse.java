package dsi.ruet.backend.dto.mealmanager;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for a single student who holds a token for a cancelled meal.
 * Maps to the Flutter StudentToken model.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentTokenResponse {
    private String studentId;       // user ID as string
    private String studentName;     // student name
    private String studentRoll;     // roll number
    private double amountPaid;      // price they paid (= meal price)
}
