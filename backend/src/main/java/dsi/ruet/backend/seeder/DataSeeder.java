package dsi.ruet.backend.seeder;

import dsi.ruet.backend.models.*;
import dsi.ruet.backend.models.enums.MealType;
import dsi.ruet.backend.models.enums.Role;
import dsi.ruet.backend.models.enums.TokenStatus;
import dsi.ruet.backend.repositories.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataSeeder implements CommandLineRunner {

    private final HallRepository hallRepository;
    private final UserRepository userRepository;
    private final WalletRepository walletRepository;
    private final MealRepository mealRepository;
    private final TokenRepository tokenRepository;

    @Override
    @Transactional
    public void run(String... args) {
        if (hallRepository.count() > 0) {
            log.info("Database already seeded — skipping.");
            return;
        }

        log.info("=== Seeding demo data ===");

        // ── Halls ────────────────────────────────────────────────────────
        Hall hall1 = hallRepository.save(Hall.builder().name("Shaheed Abdur Rab Hall").build());
        Hall hall2 = hallRepository.save(Hall.builder().name("Shaheed Shah Paran Hall").build());

        // ── Users (Hall 1 — 3 students for marketplace testing) ─────────
        User rumi   = createUser("rumi@student.ruet.ac.bd",   "Rumi Ahmed",   hall1);
        User karim  = createUser("karim@student.ruet.ac.bd",  "Karim Hassan", hall1);
        User tanvir = createUser("tanvir@student.ruet.ac.bd", "Tanvir Islam", hall1);

        // ── Users (Hall 2 — 1 student to test hall isolation) ────────────
        User sakib = createUser("sakib@student.ruet.ac.bd", "Sakib Rahman", hall2);

        // ── Wallets ──────────────────────────────────────────────────────
        createWallet(rumi,   500.0);
        createWallet(karim,  300.0);
        createWallet(tanvir, 200.0);
        createWallet(sakib,  400.0);

        // ── Meals (tomorrow, Hall 1) ─────────────────────────────────────
        LocalDate tomorrow = LocalDate.now().plusDays(1);

        Meal lunch = mealRepository.save(Meal.builder()
                .hall(hall1)
                .mealDate(tomorrow)
                .mealType(MealType.LUNCH)
                .menu("Rice, Chicken Curry, Dal, Salad")
                .price(60.0)
                .purchaseDeadline(tomorrow.atTime(10, 0))
                .build());

        Meal dinner = mealRepository.save(Meal.builder()
                .hall(hall1)
                .mealDate(tomorrow)
                .mealType(MealType.DINNER)
                .menu("Rice, Fish Curry, Vegetables")
                .price(70.0)
                .purchaseDeadline(tomorrow.atTime(17, 0))
                .build());

        // ── Tokens ───────────────────────────────────────────────────────
        // Rumi has lunch + dinner tokens → can sell either on marketplace
        Token t1 = createToken(lunch,  rumi,  TokenStatus.AVAILABLE);
        Token t2 = createToken(dinner, rumi,  TokenStatus.AVAILABLE);

        // Karim has lunch token only → can sell it, or buy dinner from marketplace
        Token t3 = createToken(lunch,  karim, TokenStatus.AVAILABLE);

        // Tanvir has NO tokens → ideal buyer on marketplace

        log.info("=== Demo data seeded ===");
        log.info("Hall 1: {} (id={})", hall1.getName(), hall1.getId());
        log.info("Hall 2: {} (id={})", hall2.getName(), hall2.getId());
        log.info("Users → Rumi(id={}), Karim(id={}), Tanvir(id={}), Sakib(id={})",
                rumi.getId(), karim.getId(), tanvir.getId(), sakib.getId());
        log.info("Tokens → Rumi: lunch(id={}) + dinner(id={}), Karim: lunch(id={})",
                t1.getId(), t2.getId(), t3.getId());
        log.info("Test scenario: Tanvir has no tokens and can be the buyer.");
        log.info("Sakib is in Hall 2 — hall isolation should block cross-hall transactions.");
    }

    private User createUser(String email, String name, Hall hall) {
        return userRepository.save(User.builder()
                .email(email)
                .password("$2a$10$placeholder_bcrypt_hash")
                .name(name)
                .hall(hall)
                .isVerified(true)
                .role(Role.STUDENT)
                .build());
    }

    private void createWallet(User user, Double balance) {
        Wallet wallet = new Wallet();
        wallet.setUser(user);
        wallet.setBalance(balance);
        walletRepository.save(wallet);
    }

    private Token createToken(Meal meal, User owner, TokenStatus status) {
        return tokenRepository.save(Token.builder()
                .meal(meal)
                .owner(owner)
                .status(status)
                .build());
    }
}
