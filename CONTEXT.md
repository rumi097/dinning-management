# Project Context — Dining Token Management System

> **Last updated:** March 1, 2026 (v2 — CoinTransaction/TokenTransaction split)
> **Team size:** 8
> **Stack:** PostgreSQL + Spring Boot 4.0.3 (Java 21) + Flutter

---

## 1. Project Description

University student hall Dining-Token management system.  
Students buy meal tokens (lunch/dinner for next day only), recharge wallets via meal manager, and trade tokens on a marketplace.

---

## 2. Roles

| Role | Description |
|------|-------------|
| **STUDENT** | Buy tokens, sell on marketplace, transfer credit within same hall |
| **MEAL_MANAGER** | Top-up student wallets, set menus/prices, view token counts, close dining (auto-refund) |
| **DINING_MANAGER** | QR-scan tokens to mark as used |

---

## 3. Business Rules

- Students can buy **at most 1 token** per meal (hall+date+type).
- Tokens are purchasable only for **next day**, within the purchase window.
- 1 credit = 1 BDT.  All real-money exchange is external.
- Each hall has **exactly 1 meal manager** at a time (selected from students).
- If meal manager closes dining → all ACTIVE/LISTED tokens are refunded and deleted.
- Admin pre-creates user accounts; students complete signup with OTP verification.

---

## 4. Database Tables (JPA entities)

| Entity | Table | PK | Key Fields |
|--------|-------|----|------------|
| `Hall` | halls | id (auto) | name |
| `User` | users | id (auto) | email, password, name, hallId, isVerified, role |
| `StudentInfo` | student_infos | id (shared PK with users) | roll, roomNo, phoneNo |
| `Wallet` | wallets | id (shared PK with users) | balance (BigDecimal) |
| `Meal` | meals | id (auto) | hall, mealDate, mealType, menu, price, purchaseStartTime, purchaseEndTime, isClosed |
| `Token` | tokens | id (auto) | meal, owner, status (ACTIVE/USED/LISTED_FOR_SALE), createdAt, usedAt |
| `CoinTransaction` | coin_transactions | id (auto) | sender, receiver, amount, type (TOPUP/TRANSACTION), createdAt |
| `TokenTransaction` | token_transactions | id (auto) | sender, receiver, token, createdAt |
| `MarketplacePost` | *(not yet created)* | — | token, seller, buyer, status |

### Unique Constraints
- `meals`: (hall_id, meal_date, meal_type)
- `users`: email
- `student_infos`: roll

---

## 5. Package Structure

```
dsi.ruet.backend
├── config/          SecurityConfig, DataInitializer
├── controllers/     AuthenticationController, AdminController, MealManagerController
├── dto/
│   ├── auth/        SignupRequest, LoginRequest, AuthResponse
│   ├── admin/       AddUserRequest
│   └── mealmanager/ TopUpRequest, SetMenuRequest, TokenSummaryResponse, TopUpHistoryResponse, DailyTopUpSummary
├── exception/       GlobalExceptionHandler, AuthenticationException, ResourceNotFoundException, DuplicateEmailException
├── models/          User, StudentInfo, Hall, Wallet, Meal, Token, CoinTransaction, TokenTransaction
├── repositories/    UserRepository, AuthUserRepository, HallRepository, StudentInfoRepository,
│                    WalletRepository, MealRepository, TokenRepository, CoinTransactionRepository, TokenTransactionRepository
├── security/        JwtTokenProvider, JwtAuthenticationFilter, CustomUserDetailsService
└── services/        AuthenticationService, AdminService, MealManagerService
```

---

## 6. API Endpoints

### Auth (`/auth`)
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /auth/signup | public | Complete signup (admin must pre-create user) |
| POST | /auth/login | public | Login, returns JWT |
| GET | /auth/me | JWT | Get current user info |

### Admin (`/admin`)
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /admin/add-user | public* | Pre-create a user account |
| GET | /admin/user?email= | public* | Get user by email |
| GET | /admin/users | public* | Get all users |
| DELETE | /admin/user?email= | public* | Delete user |

*\* Currently permitAll — should be locked down later.*

### Meal Manager (`/meal-manager`)
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /meal-manager/topup | MEAL_MANAGER | Top-up a student's wallet |
| POST | /meal-manager/set-menu | MEAL_MANAGER | Set menu/price for next day |
| GET | /meal-manager/token-summary | MEAL_MANAGER | Token count for tomorrow's meals |
| POST | /meal-manager/close-dining/{mealId} | MEAL_MANAGER | Close dining, refund tokens |
| GET | /meal-manager/topup-history | MEAL_MANAGER | Full top-up history by this manager |
| GET | /meal-manager/topup-daily?date= | MEAL_MANAGER | Daily top-up total (defaults to today) |

---

## 7. Dependencies (pom.xml)

- spring-boot-starter-data-jpa
- spring-boot-starter-webmvc
- postgresql (runtime)
- lombok
- jjwt (JWT handling)
- spring-boot-starter-security

---

## 8. TODO / Not Yet Implemented

- [ ] MarketplacePost entity + service + controller
- [ ] Student token purchase flow
- [ ] Student credit transfer (same hall)
- [ ] Dining Manager QR scan endpoint
- [ ] Real OTP verification (currently dummy)
- [ ] Proper admin role-based security
- [ ] Flutter frontend
