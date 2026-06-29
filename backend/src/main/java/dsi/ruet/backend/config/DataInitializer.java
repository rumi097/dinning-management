package dsi.ruet.backend.config;

import dsi.ruet.backend.models.*;
import dsi.ruet.backend.models.enums.*;
import dsi.ruet.backend.repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired private HallRepository hallRepository;
    @Autowired private UserRepository userRepository;
    @Autowired private PasswordEncoder passwordEncoder;
    @Autowired private WalletRepository walletRepository;
    @Autowired private MealRepository mealRepository;
    @Autowired private StudentInfoRepository studentInfoRepository;
    @Autowired private TokenRepository tokenRepository;
    @Autowired private CoinTransactionRepository coinTransactionRepository;

    @Override
    public void run(String... args) throws Exception {
        // Initialize dummy halls if they don't exist
        if (hallRepository.count() == 0) {
            hallRepository.save(new Hall(null, "Tanti Hall"));
            hallRepository.save(new Hall(null, "Rajshahi Hall"));
            hallRepository.save(new Hall(null, "Chittagong Hall"));
            hallRepository.save(new Hall(null, "Sylhet Hall"));
            hallRepository.save(new Hall(null, "Khulna Hall"));
            System.out.println("Dummy halls initialized successfully");
        }

        Hall defaultHall = hallRepository.findAll().get(0);

        // Initialize dummy users if they don't exist
        User student = createUserIfNotFound("student@test.com", "Test Student", Role.STUDENT, defaultHall);
        User mealManager = createUserIfNotFound("mealmanager@test.com", "Test Meal Manager", Role.MEAL_MANAGER, defaultHall);
        createUserIfNotFound("diningmanager@test.com", "Test Dining Manager", Role.DINING_MANAGER, defaultHall);
        
        // Add Student Info
        if (studentInfoRepository.findById(student.getId()).isEmpty()) {
            StudentInfo info = new StudentInfo(null, student, "1903001", "201", "01700000000");
            studentInfoRepository.save(info);
        }

        // Initialize dummy meals and related token data
        if (mealRepository.count() == 0) {
            Meal pastLunch = Meal.builder().hall(defaultHall).mealDate(LocalDate.now().minusDays(1)).mealType(MealType.LUNCH).menu("Rice, Fish, Daal").price(new BigDecimal("45.00")).isClosed(true).build();
            Meal todayLunch = Meal.builder().hall(defaultHall).mealDate(LocalDate.now()).mealType(MealType.LUNCH).menu("Rice, Beef, Daal").price(new BigDecimal("50.00")).isClosed(false).build();
            Meal tomorrowDinner = Meal.builder().hall(defaultHall).mealDate(LocalDate.now().plusDays(1)).mealType(MealType.DINNER).menu("Rice, Chicken, Daal").price(new BigDecimal("40.00")).isClosed(false).build();
            
            pastLunch = mealRepository.save(pastLunch);
            todayLunch = mealRepository.save(todayLunch);
            tomorrowDinner = mealRepository.save(tomorrowDinner);
            
            // Add Tokens for student
            tokenRepository.save(Token.builder().owner(student).meal(todayLunch).status(TokenStatus.AVAILABLE).createdAt(LocalDateTime.now()).build());
            tokenRepository.save(Token.builder().owner(student).meal(pastLunch).status(TokenStatus.USED).createdAt(LocalDateTime.now().minusDays(1)).usedAt(LocalDateTime.now().minusDays(1)).build());
            
            // Add Coin Transaction for student (Wallet Topup)
            coinTransactionRepository.save(CoinTransaction.builder().sender(mealManager).receiver(student).amount(500L).type(TransactionType.TOPUP).createdAt(LocalDateTime.now().minusDays(2)).build());
            
            System.out.println("Dummy meals, tokens, and transactions initialized successfully");
        }
    }

    private User createUserIfNotFound(String email, String name, Role role, Hall hall) {
        return userRepository.findByEmail(email).orElseGet(() -> {
            User user = User.builder()
                .name(name)
                .email(email)
                .password(passwordEncoder.encode("password123"))
                .role(role)
                .isVerified(true)
                .hall(hall)
                .build();
            user = userRepository.save(user);
            
            // Create a wallet for the user
            Wallet wallet = new Wallet();
            wallet.setUserId(user.getId());
            wallet.setBalance(new BigDecimal("5000.00"));
            walletRepository.save(wallet);
            
            System.out.println("Initialized dummy user: " + email);
            return user;
        });
    }
}
