# Project Context Document

## Overview
**Digital Dining Token Management System** — A mobile-based app to digitalize the physical token-based dining system in university halls.

- **Frontend:** Flutter mobile app
- **Backend:** Spring Boot 4.0.3, Java 21
- **Database:** PostgreSQL (`localhost:5432/dsiApp`)
- **Auth:** JWT (HS512) + Spring Security + BCrypt
- **ORM:** Spring Data JPA / Hibernate (ddl-auto=update)
- **API Prefix:** `/api/v1` (via context-path)

---

## Roles
| Role | Key Actions |
|------|-------------|
| STUDENT | Buy tokens, use tokens, trade on marketplace, view wallet |
| MEAL_MANAGER | Top-up wallets, set menu/price/deadline, view reports |
| DINING_MANAGER | Scan QR codes, validate tokens, view served meals |

---

## Existing Package Structure
```
dsi.ruet.backend
├── BackendApplication.java
├── config/        SecurityConfig, DataInitializer (seeds 5 halls)
├── controllers/   AuthenticationController, AdminController
├── dto/           ApiResponse<T>, ErrorResponse
│   ├── admin/     AddUserRequest
│   └── auth/      AuthResponse, LoginRequest, SignupRequest
├── exception/     GlobalExceptionHandler, AuthenticationException, DuplicateEmailException, ResourceNotFoundException
├── models/        User (implements UserDetails), Hall, StudentInfo
├── repositories/  UserRepository, AuthUserRepository, HallRepository, StudentInfoRepository, TaskRepository(empty)
├── security/      JwtTokenProvider, JwtAuthenticationFilter, CustomUserDetailsService
└── services/      AuthenticationService, AdminService
```

---

## Existing Entities

### User (table: `users`)
| Field | Type | Notes |
|-------|------|-------|
| id | Long | PK, auto-increment |
| email | String(120) | unique |
| password | String(255) | BCrypt hashed |
| name | String(120) | |
| hallId | Long | FK to halls (stored as plain Long, not @ManyToOne) |
| isVerified | Boolean | default false |
| role | String(20) | STUDENT / MEAL_MANAGER / DINING_MANAGER |

### Hall (table: `halls`)
| Field | Type |
|-------|------|
| id | Long | PK |
| name | String(100) | unique |

### StudentInfo (table: `student_infos`)
| Field | Type | Notes |
|-------|------|-------|
| id | Long | Shared PK with users via @MapsId |
| user | User | @OneToOne LAZY |
| roll | String(50) | unique |
| roomNo | String(20) | |
| phoneNo | String(20) | |

---

## Entities NOT Yet Implemented (from DB schema)

### Meal (table: `meals`) - NEEDED FOR MANAGER APIs
| Field | Type | Notes |
|-------|------|-------|
| id | Long | PK |
| hallId | Long | FK to halls |
| mealDate | LocalDate | |
| mealType | String | LUNCH / DINNER |
| menu | String (text) | |
| price | BigDecimal(8,2) | |
| purchaseDeadline | LocalDateTime | |
| Unique: (hall_id, meal_date, meal_type) |

### Token (table: `tokens`) - NEEDED FOR REPORTS
| Field | Type | Notes |
|-------|------|-------|
| id | Long | PK |
| mealId | Long | FK to meals |
| ownerId | Long | FK to users |
| status | String | ACTIVE / USED / LISTED_FOR_SALE |
| createdAt | LocalDateTime | |
| usedAt | LocalDateTime | |

### Wallet (table: `wallets`) - NEEDED FOR TOPUP REPORTS
| Field | Type | Notes |
|-------|------|-------|
| id | Long | Shared PK with users |
| balance | BigDecimal(10,2) | default 0 |

### CoinTransaction (table: `coin_transactions`) - NEEDED FOR TOPUP REPORTS
| Field | Type | Notes |
|-------|------|-------|
| id | Long | PK |
| senderId | Long | FK to users |
| receiverId | Long | FK to users |
| amount | BigDecimal(10,2) | |
| type | String | TRANSFER / TOP_UP |
| createdAt | LocalDateTime | |

---

## Conventions Used in Codebase
- **Response wrapper:** `ApiResponse<T>` with message, data, success
- **Error response:** `ErrorResponse` with message, status, timestamp
- **DI:** Mix of @Autowired field injection and constructor injection
- **Annotations:** Lombok @Data, @NoArgsConstructor, @AllArgsConstructor on entities/DTOs
- **Naming:** *Controller, *Service, *Repository
- **Transactions:** @Transactional on write operations
- **Role auth:** `@PreAuthorize("hasRole('MEAL_MANAGER')")` (method security enabled)
- **CORS:** @CrossOrigin(origins = "*") on controllers
- **hallId:** Stored as Long on User, not as @ManyToOne relationship

---

## APIs Implemented (Reporting Module — ReportController + ReportService)

### GET `/reports/sales?date=YYYY-MM-DD`
- Returns token sales breakdown for a date (lunch/dinner counts, revenue)
- Scoped to the meal manager's hall

### GET `/reports/wallet-topups?date=YYYY-MM-DD`
- Returns wallet top-up transactions for a date
- Scoped to the meal manager's hall

### GET `/reports/sales-summary`
- Returns overall sales summary (today + tomorrow stats)
- Scoped to the meal manager's hall

---

## Security Notes
- `/auth/signup`, `/auth/login` → permitAll
- `/admin/**` → authenticated, restricted to MEAL_MANAGER role (e.g. `hasRole('MEAL_MANAGER')`)
- Everything else → authenticated
- Method-level: `@PreAuthorize` annotations for role checking
- JWT claims contain: sub=email, role=user_role
