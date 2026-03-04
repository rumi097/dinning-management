# Digital Dining Token Management System — Full Codebase Context

> **Last Updated:** March 3, 2026  
> **Branch:** `feature/marketplace` (commit `6703a90`)  
> **Repo:** `sadat2103108/Dining-Token-Digitalization`  
> **Stack:** Spring Boot 4.0.3 · Java 21 · PostgreSQL (`dsiApp` on `localhost:5432`) · Hibernate 7.2.4 · Lombok · Flutter (frontend)  
> **Base URL:** `http://localhost:8080/api/v1` (via `server.servlet.context-path`)  
> **Auth:** JWT Bearer Token (HS512, 24h expiry) + `X-User-Id` header for marketplace endpoints

---

## Table of Contents

1. [Project Structure](#1-project-structure)
2. [Configuration](#2-configuration)
3. [Models & Enums](#3-models--enums)
4. [Repositories](#4-repositories)
5. [Services](#5-services)
6. [Controllers & Endpoints](#6-controllers--endpoints)
7. [DTOs](#7-dtos)
8. [Security](#8-security)
9. [Exception Handling](#9-exception-handling)
10. [Marketplace Feature](#10-marketplace-feature)
11. [Known Issues & Notes](#11-known-issues--notes)

---

## 1. Project Structure

```
backend/src/main/java/dsi/ruet/backend/
├── BackendApplication.java          # @SpringBootApplication + @EnableScheduling
├── common/
│   ├── dto/
│   │   ├── ApiResponse.java         # Generic API response (marketplace uses this)
│   │   ├── TokenResponse.java       # Marketplace token DTO (Long price)
│   │   └── UserResponse.java        # Common user DTO
│   └── exception/
│       └── MarketplaceExceptionHandler.java
├── config/
│   ├── DataInitializer.java         # Seeds 5 halls on startup
│   └── SecurityConfig.java          # JWT + stateless security config
├── controllers/
│   ├── AdminController.java         # /admin endpoints
│   ├── AuthenticationController.java # /auth endpoints
│   ├── MealManagerController.java   # Wallet, meals, dashboard, refunds (292 lines)
│   ├── ReportController.java        # /reports endpoints
│   └── TokenController.java         # /tokens endpoints
├── dto/
│   ├── ApiResponse.java             # Generic API response (non-marketplace)
│   ├── ErrorResponse.java           # Error wrapper
│   ├── admin/                       # AddUserRequest, AddHallRequest, UserResponse
│   ├── auth/                        # AuthResponse, LoginRequest, SignupRequest, OTP DTOs
│   ├── manager/                     # SalesReportResponse, SalesSummaryResponse, WalletTopupReportResponse
│   ├── mealmanager/                 # 20 DTOs for meal manager operations
│   └── token/                       # PurchaseTokenRequest, QrResponse, TokenResponse, etc.
├── exception/
│   ├── AuthenticationException.java
│   ├── DuplicateEmailException.java
│   ├── GlobalExceptionHandler.java
│   └── ResourceNotFoundException.java
├── marketplace/
│   ├── MarketplaceController.java   # /marketplace endpoints (10 endpoints)
│   ├── MarketplacePost.java         # Entity
│   ├── MarketplaceRepository.java   # JPA repository
│   ├── MarketplaceScheduler.java    # 15-min timeout scheduler
│   ├── MarketplaceService.java      # Business logic (536 lines)
│   ├── dto/
│   │   ├── BuyRequest.java
│   │   ├── MarketplacePostResponse.java
│   │   └── SellRequest.java
│   └── exception/
│       └── MarketplaceException.java
├── models/
│   ├── CoinTransaction.java
│   ├── Hall.java
│   ├── Meal.java
│   ├── StudentInfo.java
│   ├── Token.java
│   ├── TokenTransaction.java
│   ├── User.java
│   ├── Wallet.java
│   └── enums/
│       ├── MarketplacePostStatus.java
│       ├── MealType.java
│       ├── Role.java
│       ├── TokenStatus.java
│       └── TransactionType.java
├── repositories/
│   ├── AuthUserRepository.java      # Duplicate of UserRepository
│   ├── CoinTransactionRepository.java
│   ├── HallRepository.java
│   ├── MealRepository.java
│   ├── StudentInfoRepository.java
│   ├── TaskRepository.java          # Empty class
│   ├── TokenRepository.java
│   ├── TokenTransactionRepository.java
│   ├── UserRepository.java
│   └── WalletRepository.java
├── security/
│   ├── CustomUserDetailsService.java
│   ├── JwtAuthenticationFilter.java
│   └── JwtTokenProvider.java
└── services/
    ├── AdminService.java
    ├── AuthenticationService.java   # 389 lines, OTP flow
    ├── MealManagerService.java      # 850 lines
    ├── ReportService.java
    ├── TokenService.java            # Interface
    └── impl/
        └── TokenServiceImpl.java    # 320 lines
```

---

## 2. Configuration

### `application.properties`

```properties
spring.application.name=backend
spring.datasource.url=jdbc:postgresql://localhost:5432/dsiApp
spring.datasource.username=aliazgorrumi
spring.datasource.password=
server.servlet.context-path=/api/v1
spring.jpa.hibernate.ddl-auto=update
spring.jpa.database-platform=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
logging.level.dsi.ruet.backend=DEBUG
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=your-email@gmail.com
spring.mail.password=your-app-password
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true
app.mail.from=your-email@gmail.com
spring.profiles.active=dev
```

### `SecurityConfig.java`

- CSRF disabled, stateless sessions
- **Public:** `/auth/signup`, `/auth/login`, `/auth/send-otp`, `/auth/verify-otp`, `/admin/**`
- **MEAL_MANAGER only:** `/api/v1/**`
- **Authenticated:** everything else
- JWT filter added before `UsernamePasswordAuthenticationFilter`
- BCrypt password encoder

### `DataInitializer.java`

Seeds 5 halls on first run: Tanti Hall, Rajshahi Hall, Chittagong Hall, Sylhet Hall, Khulna Hall.

---

## 3. Models & Enums

### Enums

| Enum | Values |
|------|--------|
| `Role` | `STUDENT`, `MEAL_MANAGER`, `DINING_MANAGER` |
| `TokenStatus` | `AVAILABLE`, `IN_QUEUE`, `USED`, `LISTED`, `CANCELLED` |
| `TransactionType` | `TOPUP`, `TRANSACTION` |
| `MealType` | `LUNCH`, `DINNER` |
| `MarketplacePostStatus` | `OPEN`, `PENDING`, `COMPLETED` |

### `User` (table: `users`)

```java
@Entity @Table(name = "users")
public class User implements UserDetails {
    Long id;                              // @GeneratedValue IDENTITY
    String email;                         // unique, not null
    @Column(name = "pass") String password; // DB column is "pass"
    String name;                          // not null
    @ManyToOne Hall hall;                  // FK hall_id, not null
    Boolean isVerified = false;
    @Enumerated(STRING) Role role;
    // Spring Security: getAuthorities() → ROLE_<role>, getUsername() → email
    // isEnabled() → isVerified
}
```

### `Wallet` (table: `wallets`)

```java
@Entity @Table(name = "wallets")
public class Wallet {
    @Id Long userId;             // PK = user_id
    Long id;                     // also FK to users.id (= userId)
    BigDecimal balance = BigDecimal.ZERO;  // precision=10, scale=2
    void setUser(User u)         // sets both userId and id
    void deduct(BigDecimal|Long) // subtract from balance
    void credit(BigDecimal|Long) // add to balance
}
```

### `Meal` (table: `meals`)

```java
@Entity @Table(name = "meals", uniqueConstraints = {hall_id, meal_date, meal_type})
public class Meal {
    Long id;
    @ManyToOne Hall hall;
    Long hallId;                    // read-only duplicate column
    LocalDate mealDate;
    @Enumerated(STRING) MealType mealType;
    String menu;                    // TEXT
    LocalDateTime purchaseStartTime;
    LocalDateTime purchaseEndTime;
    LocalDateTime purchaseDeadline;
    BigDecimal price;               // precision=8, scale=2
    Boolean isClosed = false;
    LocalDateTime refundedAt;       // null = not yet refunded
}
```

### `Token` (table: `tokens`)

```java
@Entity @Table(name = "tokens", uniqueConstraints = {owner_id, meal_id})
public class Token {
    Long id;
    @ManyToOne Meal meal;
    @ManyToOne User owner;
    @Enumerated(STRING) TokenStatus status;
    LocalDateTime createdAt;        // auto-set via @PrePersist
    LocalDateTime usedAt;
    String qrCode;                  // format: "TOKEN:<id>:<uuid>"
}
```

### `CoinTransaction` (table: `coin_transactions`)

```java
@Entity @Table(name = "coin_transactions")
public class CoinTransaction {
    Long id;
    @ManyToOne User sender;
    @ManyToOne User receiver;
    Long amount;                    // monetary amount as Long
    @Enumerated(STRING) TransactionType type;
    LocalDateTime createdAt;        // auto-set via @PrePersist
}
```

### `TokenTransaction` (table: `token_transactions`)

```java
@Entity @Table(name = "token_transactions")
public class TokenTransaction {
    Long id;
    @ManyToOne User sender;
    @ManyToOne User receiver;
    @ManyToOne Token token;
    LocalDateTime createdAt;        // auto-set via @PrePersist
}
```

### `Hall` (table: `halls`)

```java
@Entity @Table(name = "halls")
public class Hall {
    Long id;
    String name;  // unique, not null
}
```

### `StudentInfo` (table: `student_infos`)

```java
@Entity @Table(name = "student_infos")
public class StudentInfo {
    @Id Long id;
    @OneToOne @MapsId User user;  // shared PK with users
    String roll;                   // unique, not null
    String roomNo;
    String phoneNo;                // not null
}
```

### `MarketplacePost` (table: `marketplace_posts`)

```java
@Entity @Table(name = "marketplace_posts")
public class MarketplacePost {
    Long id;
    @ManyToOne Token token;
    @ManyToOne User seller;
    @ManyToOne User buyer;          // null when OPEN
    @Enumerated(STRING) MarketplacePostStatus status;
    LocalDateTime createdAt;
    LocalDateTime buyerRequestedAt; // 15-min timer start
    @Enumerated(STRING) TransactionType paymentType; // TRANSACTION or TOPUP
}
```

---

## 4. Repositories

### `UserRepository`

```java
Optional<User> findByEmail(String email);
boolean existsByEmail(String email);
@Query long countByHallIdAndRole(Long hallId, Role role);
```

### `WalletRepository`

```java
Optional<Wallet> findByUserId(Long userId);
```

### `MealRepository`

```java
List<Meal> findByHallIdAndMealDate(Long hallId, LocalDate mealDate);
Optional<Meal> findByHallIdAndMealDateAndMealType(Long hallId, LocalDate mealDate, MealType mealType);
List<Meal> findByHallId(Long hallId);
List<Meal> findByHallIdAndMealDateBetweenOrderByMealDateDesc(Long hallId, LocalDate start, LocalDate end);
List<Meal> findByHallIdAndIsClosedTrueAndRefundedAtIsNull(Long hallId);
List<Meal> findByHallIdAndIsClosedTrueAndRefundedAtIsNotNullOrderByRefundedAtDesc(Long hallId);
long countByHallIdAndIsClosedTrueAndRefundedAtIsNull(Long hallId);
long countByHallIdAndIsClosedTrueAndRefundedAtIsNotNull(Long hallId);
```

### `TokenRepository`

```java
// Marketplace
List<Token> findByOwnerId(Long ownerId);
List<Token> findByOwnerIdAndStatus(Long ownerId, TokenStatus status);
boolean existsByOwnerIdAndMealId(Long ownerId, Long mealId);

// Meal manager
List<Token> findByMealId(Long mealId);
Optional<Token> findByMealIdAndOwnerId(Long mealId, Long ownerId);
long countByMealId(Long mealId);
List<Token> findByMealIdIn(List<Long> mealIds);
@Query long countByMealIdIn(List<Long> mealIds);
@Query long countByMealIdAndStatus(Long mealId, TokenStatus status);

// Student
List<Token> findByOwnerOrderByCreatedAtDesc(User owner);
boolean existsByOwnerAndMeal(User owner, Meal meal);
Optional<Token> findByQrCode(String qrCode);
```

### `CoinTransactionRepository`

```java
List<CoinTransaction> findBySenderIdAndType(Long senderId, TransactionType type);
List<CoinTransaction> findBySenderIdOrReceiverId(Long senderId, Long receiverId);
List<CoinTransaction> findBySenderIdAndTypeOrderByCreatedAtDesc(Long senderId, TransactionType type);
@Query Long sumTopUpBySenderAndDay(Long senderId, LocalDateTime dayStart, LocalDateTime dayEnd);
@Query List<CoinTransaction> findTopUpsBySenderAndDateRange(Long senderId, LocalDateTime start, LocalDateTime end);
@Query long countTopUpsBySenderAndDay(Long senderId, LocalDateTime dayStart, LocalDateTime dayEnd);
@Query List<CoinTransaction> findRefundsBySenderAndDateRange(Long senderId, LocalDateTime start, LocalDateTime end);
@Query List<CoinTransaction> findTopUpsByReceiverIdsAndDate(List<Long> userIds, LocalDateTime start, LocalDateTime end);
@Query Long sumTopUpsByReceiverIdsAndDate(List<Long> userIds, LocalDateTime start, LocalDateTime end);
```

### `TokenTransactionRepository`

```java
List<TokenTransaction> findByTokenId(Long tokenId);
List<TokenTransaction> findBySenderIdOrReceiverId(Long senderId, Long receiverId);
```

### `StudentInfoRepository`

```java
Optional<StudentInfo> findByRoll(String roll);
```

### `HallRepository`

```java
Optional<Hall> findByName(String name);
```

### `MarketplaceRepository`

```java
@Query List<MarketplacePost> findByStatusAndHallId(MarketplacePostStatus status, Long hallId);
@Query List<MarketplacePost> findBySellerIdAndStatusIn(Long sellerId, List<MarketplacePostStatus> statuses);
@Query List<MarketplacePost> findByBuyerIdAndStatus(Long buyerId, MarketplacePostStatus status);
@Query List<MarketplacePost> findTimedOutPendingPosts(MarketplacePostStatus status, LocalDateTime cutoff);
boolean existsByTokenIdAndStatusIn(Long tokenId, List<MarketplacePostStatus> statuses);
Optional<MarketplacePost> findFirstByTokenIdAndStatusIn(Long tokenId, List<MarketplacePostStatus> statuses);
```

### Others

- `AuthUserRepository` — duplicate of `UserRepository` (findByEmail, existsByEmail)
- `TaskRepository` — empty class (unused)

---

## 5. Services

### `AdminService`

| Method | Description |
|--------|-------------|
| `addUser(AddUserRequest)` | Create placeholder user (password="CHANGE_THIS", isVerified=false) |
| `getAllUsers()` | List all users with StudentInfo |
| `getUserByEmail(email)` | Get single user by email |
| `deleteUserByEmail(email)` | Delete user + StudentInfo |
| `addHall(AddHallRequest)` | Add new hall (unique name) |

### `AuthenticationService` (389 lines)

| Method | Description |
|--------|-------------|
| `sendOtp(email)` | Generate random 6-digit OTP, store in memory (5-min expiry), send email via JavaMailSender |
| `verifyOtp(email, otp)` | Validate OTP, set `user.isVerified = true` |
| `signup(SignupRequest)` | Full signup: requires pre-verified email, sets password/name, creates StudentInfo + Wallet(balance=0) |
| `login(LoginRequest)` | Authenticate, generate JWT, return user info + StudentInfo |
| `getCurrentUser(email)` | Return current user info from JWT (no token in response) |

**OTP Flow:** `sendOtp` → `verifyOtp` → `signup` → `login`

### `MealManagerService` (850 lines)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `topUpWallet` | POST /wallet/topup | Credit student wallet, record TOPUP transaction |
| `getStudentBalance` | GET /wallet/student/{roll} | Lookup by roll number |
| `getWalletHistory` | GET /wallet/history?date= | TOPUP transactions by manager on date |
| `createMealConfig` | POST /meals/config | Create meal for tomorrow (unique hall+date+type) |
| `updateMealConfig` | PUT /meals/config/{id} | Update existing meal |
| `getTomorrowConfig` | GET /meals/config/tomorrow | Tomorrow's meals for manager's hall |
| `getMealConfigByDate` | GET /meals/config/{date} | Meals for specific date |
| `getMealAvailability` | GET /meals/availability/{date} | Check if lunch/dinner open |
| `updateMealAvailability` | PUT /meals/availability/{date} | Close meal + auto-refund tokens |
| `getSalesReport` | GET /reports/sales?date= | Token count by meal type |
| `getRevenueReport` | (internal) | Revenue = count × price |
| `getWalletTopups` | GET /reports/wallet-topups?date= | Same as wallet history |
| `getDashboardData` | GET /dashboard | Today's aggregated stats |
| `getMealHistory` | GET /history/meals | Last 30 days meal history |
| `getCreditHistory` | GET /history/credits | Last 30 days topup history |
| `getRefundableMeals` | GET /refunds/pending | Closed meals not yet refunded |
| `getRefundSummary` | GET /refunds/summary | Pending + completed counts/amounts |
| `processRefund` | POST /refunds/process | Refund single meal |
| `processBulkRefund` | POST /refunds/process-bulk | Refund multiple meals |
| `getRefundHistory` | GET /refunds/history | Already-refunded meals |

### `TokenService` → `TokenServiceImpl` (320 lines)

| Method | Description |
|--------|-------------|
| `purchaseToken` | Validate deadline + balance + no-duplicate, deduct wallet, create token + QR, record transaction |
| `getMyTokens` | All tokens owned by user, newest first |
| `getTokenById` | Single token (owner or ADMIN only) |
| `generateQr` | Generate QR string for AVAILABLE token |
| `validateQr` | Parse QR → validate token status + today's date |
| `markTokenUsed` | Set status=USED + usedAt timestamp |
| `transferToken` | Change owner, regenerate QR, record TokenTransaction |

### `ReportService`

| Method | Endpoint | Description |
|--------|----------|-------------|
| `getSalesReport` | GET /reports/sales?date= | Per-meal breakdown: sold/used/active counts + revenue |
| `getWalletTopupReport` | GET /reports/wallet-topups?date= | All topups for hall users on date |
| `getSalesSummary` | GET /reports/sales-summary | Today + tomorrow stats + meal configs |

### `MarketplaceService` (536 lines)

See [Section 10](#10-marketplace-feature).

---

## 6. Controllers & Endpoints

### Admin — `/admin` (public, no auth required)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/admin/add-user` | Add placeholder user |
| GET | `/admin/user?email=` | Get user by email |
| GET | `/admin/users` | Get all users |
| DELETE | `/admin/user?email=` | Delete user by email |
| POST | `/admin/add-hall` | Add new hall |

### Authentication — `/auth`

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/auth/send-otp?email=` | Public | Send OTP email |
| POST | `/auth/verify-otp?email=&otp=` | Public | Verify OTP |
| POST | `/auth/signup` | Public | Complete signup |
| POST | `/auth/login` | Public | Login → JWT |
| GET | `/auth/me` | JWT | Current user info |

### Meal Manager (requires `MEAL_MANAGER` role + JWT)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/wallet/topup` | Top up student wallet |
| GET | `/wallet/student/{roll}` | Get student balance |
| GET | `/wallet/history?date=` | Topup history for date |
| POST | `/meals/config` | Create meal config (tomorrow) |
| PUT | `/meals/config/{id}` | Update meal config |
| GET | `/meals/config/tomorrow` | Tomorrow's configs |
| GET | `/meals/config/{date}` | Configs for specific date |
| GET | `/meals/availability/{date}` | Meal availability |
| PUT | `/meals/availability/{date}` | Update availability (close + refund) |
| GET | `/dashboard` | Dashboard aggregation |
| GET | `/history/meals` | 30-day meal history |
| GET | `/history/credits` | 30-day credit history |
| GET | `/refunds/pending` | Pending refundable meals |
| GET | `/refunds/summary` | Refund stats |
| POST | `/refunds/process` | Process single refund |
| POST | `/refunds/process-bulk` | Process bulk refunds |
| GET | `/refunds/history` | Refund history |

### Reports — `/reports` (requires `MEAL_MANAGER` role + JWT)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/reports/sales?date=` | Sales report by meal type |
| GET | `/reports/wallet-topups?date=` | Topup report |
| GET | `/reports/sales-summary` | Today + tomorrow summary |

### Tokens — `/tokens` (JWT required)

| Method | Path | Role | Description |
|--------|------|------|-------------|
| POST | `/tokens/purchase` | STUDENT | Purchase token |
| GET | `/tokens/me` | STUDENT | My tokens |
| GET | `/tokens/{id}` | STUDENT/ADMIN | Token by ID |
| POST | `/tokens/{id}/generate-qr` | STUDENT | Generate QR |
| POST | `/tokens/validate-qr` | MEAL_MANAGER/DINING_MANAGER | Validate QR |
| POST | `/tokens/{id}/mark-used` | MEAL_MANAGER/DINING_MANAGER | Mark used |
| POST | `/tokens/transfer` | STUDENT/ADMIN | Transfer token |

### Marketplace — `/marketplace` (uses `X-User-Id` header)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/marketplace/posts` | Browse OPEN listings (same hall) |
| GET | `/marketplace/my-tokens` | My AVAILABLE tokens |
| POST | `/marketplace/sell` | List token for sale |
| DELETE | `/marketplace/{id}` | Cancel listing (OPEN only) |
| POST | `/marketplace/buy` | Send buy request → PENDING |
| POST | `/marketplace/purchases/{id}/cancel` | Buyer cancels request |
| POST | `/marketplace/listings/{id}/confirm` | Seller confirms transfer |
| POST | `/marketplace/listings/{id}/reject` | Seller rejects request |
| GET | `/marketplace/my-listings` | My OPEN+PENDING listings |
| GET | `/marketplace/my-purchases` | My PENDING purchases |

---

## 7. DTOs

### Top-Level (`dto/`)

| DTO | Fields |
|-----|--------|
| `ApiResponse<T>` | message, data, success |
| `ErrorResponse` | message, status, timestamp |

### Admin (`dto/admin/`)

| DTO | Fields |
|-----|--------|
| `AddUserRequest` | id, email, hallId, role |
| `AddHallRequest` | name (validated @NotBlank) |
| `UserResponse` | id, email, name, hallId, isVerified, role, roll, phoneNo, roomNo |

### Auth (`dto/auth/`)

| DTO | Fields |
|-----|--------|
| `LoginRequest` | email, password |
| `SignupRequest` | email, password, name, roll, phoneNo, roomNo |
| `SignupResponse` | message, email, userId |
| `AuthResponse` | token, email, role, name, userId, hallId, hallName, roll, phoneNo, roomNo |
| `OtpResponse` | message, email, success |
| `OtpVerificationResponse` | message, email, verified |

### Manager/Reports (`dto/manager/`)

| DTO | Key Fields |
|-----|------------|
| `SalesReportResponse` | date, hallId, meals (List\<MealSalesDetail\>), totalTokensSold, totalRevenue (BigDecimal) |
| `SalesSummaryResponse` | today/tomorrow token counts + revenue (BigDecimal), tomorrowMealConfigs |
| `WalletTopupReportResponse` | date, hallId, totalTopups, totalAmount (BigDecimal), topups list |

### Meal Manager (`dto/mealmanager/`)

| DTO | Key Fields |
|-----|------------|
| `TopUpRequest` | studentId (roll), amount (BigDecimal) |
| `StudentBalanceResponse` | studentId, studentName, balance (BigDecimal) |
| `CreditTransactionResponse` | id, studentId, studentName, amount (BigDecimal), timestamp |
| `SetMenuRequest` | mealType, menu, price (BigDecimal), purchaseStartTime, purchaseEndTime |
| `MealConfigResponse` | id, date, mealType, price (BigDecimal), menu, deadline, startTime, endTime, isClosed |
| `MealAvailabilityRequest` | date, isLunchAvailable, isDinnerAvailable |
| `MealAvailabilityResponse` | date, isMealAvailable, isLunchAvailable, isDinnerAvailable |
| `DashboardResponse` | lunchCount, dinnerCount, revenue (double), totalStudents, todayTopUps, availability |
| `DailyMealHistoryResponse` | date, lunchCount, dinnerCount, lunchPrice (double), dinnerPrice (double) |
| `DailyCreditHistoryResponse` | date, transactions list (amount as double) |
| `SalesReportResponse` | lunchSold, dinnerSold |
| `RevenueReportResponse` | lunchRevenue (double), dinnerRevenue (double) |
| `RefundableMealResponse` | id, date, mealType, tokensSold, pricePerToken (double), totalRefundAmount, students, status |
| `StudentTokenResponse` | studentId, studentName, studentRoll, amountPaid (double) |
| `RefundSummaryResponse` | pendingCount, completedCount, totalAmountPending (double), totalAmountRefunded (double) |
| `ProcessRefundRequest` | mealId (String) |
| `BulkRefundRequest` | mealIds (List\<String\>) |
| `TokenSummaryResponse` | mealId, mealType, mealDate, totalTokensBought, isClosed |
| `DailyTopUpSummary` | date, totalAmount (BigDecimal), transactionCount |
| `TopUpHistoryResponse` | transactionId, studentId, studentName, studentEmail, amount (BigDecimal), createdAt |

### Token (`dto/token/`)

| DTO | Key Fields |
|-----|------------|
| `PurchaseTokenRequest` | mealId (Long, @NotNull) |
| `TokenResponse` | id, mealId, mealType, mealDate, price (BigDecimal), menu, status, ownerName, createdAt, usedAt |
| `QrResponse` | tokenId, qrCode |
| `QrValidationResponse` | valid, tokenId, ownerName, mealType, mealDate, status, message |
| `TransferTokenRequest` | tokenId (Long), receiverEmail (String) |
| `ValidateQrRequest` | qrData (String, @NotBlank) |

### Common (`common/dto/`) — Used by Marketplace

| DTO | Key Fields |
|-----|------------|
| `ApiResponse<T>` | success, message, data + static `success()`/`error()` builders |
| `TokenResponse` | id, mealId, mealType, mealDate, menu, price (**Long**), status |
| `UserResponse` | id, name, email, hallId, hallName, role |

### Marketplace (`marketplace/dto/`)

| DTO | Key Fields |
|-----|------------|
| `SellRequest` | tokenId (Long) |
| `BuyRequest` | postId (Long), paymentType (String: "TRANSACTION" or "TOPUP") |
| `MarketplacePostResponse` | id, tokenId, mealType, mealDate, mealMenu, mealPrice (**Long**), sellerId, sellerName, buyerId, buyerName, status, paymentType, createdAt, buyerRequestedAt |

---

## 8. Security

### JWT Configuration

- **Secret:** `mySecretKeyForJWTTokenGenerationThatIsAtLeast256BitsLongForHS256Algorithm` (default)
- **Expiry:** 24 hours (86400000ms)
- **Algorithm:** HS512
- **Claims:** `sub` = email, `role` = user role (without ROLE_ prefix)

### `JwtAuthenticationFilter`

- Extracts `Bearer <token>` from `Authorization` header
- Validates token → loads `UserDetails` → sets `SecurityContext`
- Silently ignores invalid tokens (no 401 thrown from filter)

### `CustomUserDetailsService`

- Loads `User` entity by email (User implements `UserDetails`)
- `isEnabled()` returns `isVerified` — unverified users cannot authenticate

### Auth Flow

1. Admin creates user via `/admin/add-user` (placeholder, unverified)
2. User calls `/auth/send-otp` → receives OTP via email
3. User calls `/auth/verify-otp` → `isVerified = true`
4. User calls `/auth/signup` → sets password, name, StudentInfo, Wallet
5. User calls `/auth/login` → receives JWT token

---

## 9. Exception Handling

### `GlobalExceptionHandler` (handles non-marketplace exceptions)

| Exception | HTTP Status |
|-----------|-------------|
| `DuplicateEmailException` | 409 Conflict |
| `ResourceNotFoundException` | 404 Not Found |
| `AuthenticationException` | 401 Unauthorized |
| `UsernameNotFoundException` | 401 Unauthorized |
| `BadCredentialsException` | 401 Unauthorized |
| `IllegalArgumentException` | 400 Bad Request |
| `IllegalStateException` | 500 Internal Server Error |
| `AccessDeniedException` | 403 Forbidden |
| `Exception` (catch-all) | 500 Internal Server Error |

### `MarketplaceExceptionHandler`

| Exception | HTTP Status |
|-----------|-------------|
| `MarketplaceException` | 400 Bad Request |
| `IllegalStateException` | 400 Bad Request |
| `Exception` (catch-all) | 500 Internal Server Error |

---

## 10. Marketplace Feature

### Overview

Peer-to-peer token resale system within the same hall. Sellers list AVAILABLE tokens; buyers send requests; sellers confirm/reject within 15 minutes.

### Flow

```
1. Seller lists token     → Token: AVAILABLE → LISTED, Post: OPEN
2. Buyer sends request    → Post: OPEN → PENDING (15-min timer starts)
3a. Seller confirms       → Token: LISTED → AVAILABLE (new owner), Post: COMPLETED
3b. Seller rejects        → Post: PENDING → OPEN
3c. Buyer cancels         → Post: PENDING → OPEN
3d. 15-min timeout        → Post: PENDING → OPEN (via scheduler)
4. Seller cancels listing → Token: LISTED → AVAILABLE, Post: deleted
```

### Payment Types

- **TRANSACTION** — In-app wallet transfer: buyer wallet debited, seller wallet credited, CoinTransaction recorded
- **TOPUP** — External payment (cash, etc.): no wallet changes

### Scheduler

- `MarketplaceScheduler` runs every 60 seconds
- Expires PENDING posts where `buyerRequestedAt < now - 15 minutes`
- Rolls them back to OPEN status

### Validations

- Seller must own the token
- Token must be AVAILABLE to list
- No duplicate active listings for same token
- Can't buy own listing
- Buyer must be in same hall as seller
- Buyer must not already own a token for that meal
- Buyer must have sufficient wallet balance (TRANSACTION type)

---

## 11. Known Issues & Notes

### Type Inconsistencies

1. **Two `ApiResponse` classes:**
   - `dsi.ruet.backend.dto.ApiResponse` — used by Admin, Auth, MealManager, Report, Token controllers
   - `dsi.ruet.backend.common.dto.ApiResponse` — used by Marketplace (has static `success()`/`error()` builders)

2. **Two `TokenResponse` classes:**
   - `dsi.ruet.backend.dto.token.TokenResponse` — uses `BigDecimal price` (token service)
   - `dsi.ruet.backend.common.dto.TokenResponse` — uses `Long price` (marketplace)

3. **Monetary field types are mixed:**
   - `CoinTransaction.amount` → `Long`
   - `Wallet.balance` → `BigDecimal`
   - `Meal.price` → `BigDecimal`
   - Dashboard/history DTOs use `double`
   - Marketplace DTOs use `Long`

4. **`TransactionType` enum has only `TOPUP` and `TRANSACTION`**, but `MealManagerService.recordCoinTransaction()` passes `"REFUND"` which maps to `TRANSACTION` (not a real REFUND type).

5. **DB constraint `coin_transactions_type_check`** may only allow `TOPUP`, `PURCHASE`, `REFUND` — but the code uses `TOPUP` and `TRANSACTION`. This could cause runtime errors.

### Unused/Duplicate Code

- `AuthUserRepository` is a duplicate of `UserRepository`
- `TaskRepository` is an empty class
- `MealManagerService.getSalesReport()` and `ReportService.getSalesReport()` overlap

### Database Notes

- `User.password` → mapped to DB column `pass` via `@Column(name = "pass")`
- `ddl-auto=update` — Hibernate auto-creates/updates schema
- DB: PostgreSQL `dsiApp` on `localhost:5432`, user `aliazgorrumi`, no password

### Security Notes

- `/admin/**` is fully public (no authentication required)
- Marketplace uses `X-User-Id` header (no JWT verification for user identity)
- JWT secret is hardcoded as default value
- OTP is random 6-digit, stored in-memory HashMap (not Redis/DB — lost on restart)
