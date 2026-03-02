# Digital Dining Token Management System — Complete Documentation

> **Project**: DSI RUET — Hall-based Meal Token Marketplace  
> **Backend**: Spring Boot 4.0.3 · Java 21 · PostgreSQL 14 · Hibernate 7  
> **Frontend**: Flutter 3.9+ · Dart · `http` package  
> **Architecture**: Feature-per-folder (modular monolith)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture & Folder Structure](#2-architecture--folder-structure)
3. [Database Schema & Entity Models](#3-database-schema--entity-models)
4. [Enums](#4-enums)
5. [Repositories](#5-repositories)
6. [Marketplace Module — Deep Dive](#6-marketplace-module--deep-dive)
   - [Entity](#61-marketplacepost-entity)
   - [Repository & Queries](#62-marketplace-repository--queries)
   - [Service — Every Method Explained](#63-marketplace-service--every-method-explained)
   - [Controller — Every Endpoint](#64-marketplace-controller--every-endpoint)
   - [Scheduler](#65-marketplace-scheduler)
   - [DTOs](#66-dtos)
   - [Exception](#67-custom-exception)
7. [Common Module](#7-common-module)
8. [Data Seeder](#8-data-seeder)
9. [Flutter Frontend — Test UI](#9-flutter-frontend--test-ui)
10. [Business Rules & Validation Summary](#10-business-rules--validation-summary)
11. [Complete Marketplace Flow](#11-complete-marketplace-flow)
12. [API Reference](#12-api-reference)
13. [Configuration](#13-configuration)

---

## 1. Project Overview

The system manages meal tokens for RUET university dining halls. Students purchase tokens (representing a specific meal on a specific date) using a digital wallet balance. The **marketplace** allows students who already own a token to resell it to another student within the same hall — a peer-to-peer secondary market.

### Key concepts

| Concept | Description |
|---------|-------------|
| **Hall** | A residential hall (hostel). Students belong to exactly one hall and can only interact with their hall's meals and marketplace. |
| **Meal** | A specific meal event — defined by hall, date, type (LUNCH/DINNER), menu, and price. |
| **Token** | Proof of a meal purchase. One token per student per meal (enforced via unique constraint). Has a lifecycle: `AVAILABLE → LISTED → (sold) → AVAILABLE (new owner)`. |
| **Wallet** | A digital coin balance linked 1:1 to a user. Supports `deduct()` and `credit()` operations. |
| **Marketplace Post** | A listing created when a student puts a token up for sale. Has a lifecycle: `OPEN → PENDING → COMPLETED`. |

### Current auth approach

Authentication is not yet implemented (awaiting the auth team). As a temporary measure, all endpoints accept an `X-User-Id` HTTP header to identify the calling user. This will be replaced with JWT-based authentication.

---

## 2. Architecture & Folder Structure

```
backend/src/main/java/dsi/ruet/backend/
├── BackendApplication.java          # @SpringBootApplication + @EnableScheduling
│
├── models/                          # SHARED entities (used across features)
│   ├── enums/
│   │   ├── Role.java                # STUDENT, MEAL_MANAGER, DINING_MANAGER
│   │   ├── MealType.java            # LUNCH, DINNER
│   │   ├── TokenStatus.java         # AVAILABLE, IN_QUEUE, USED, LISTED
│   │   ├── TransactionType.java     # TOPUP, TRANSACTION
│   │   └── MarketplacePostStatus.java  # OPEN, PENDING, COMPLETED
│   ├── Hall.java
│   ├── User.java
│   ├── Wallet.java
│   ├── StudentInfo.java
│   ├── Meal.java
│   ├── Token.java
│   ├── CoinTransaction.java
│   └── TokenTransaction.java
│
├── repositories/                    # SHARED Spring Data JPA repos
│   ├── HallRepository.java
│   ├── UserRepository.java
│   ├── WalletRepository.java
│   ├── MealRepository.java
│   ├── TokenRepository.java
│   ├── TokenTransactionRepository.java
│   └── CoinTransactionRepository.java
│
├── marketplace/                     # ★ FEATURE MODULE (self-contained)
│   ├── MarketplacePost.java         # Entity
│   ├── MarketplaceRepository.java   # JPA repo with custom JPQL queries
│   ├── MarketplaceService.java      # 12 public methods, all business logic
│   ├── MarketplaceController.java   # 10 REST endpoints
│   ├── MarketplaceScheduler.java    # @Scheduled — 15-min timeout
│   ├── dto/
│   │   ├── SellRequest.java         # Input DTO — sell a token
│   │   ├── BuyRequest.java          # Input DTO — buy with payment type
│   │   └── MarketplacePostResponse.java  # Output DTO
│   └── exception/
│       └── MarketplaceException.java
│
├── common/                          # Cross-cutting concerns
│   ├── config/
│   │   └── CorsConfig.java          # Allows all origins on /api/**
│   ├── dto/
│   │   ├── ApiResponse.java         # Generic { success, message, data }
│   │   ├── UserResponse.java        # User DTO for API output
│   │   └── TokenResponse.java       # Token DTO for API output
│   ├── controller/
│   │   └── TestHelperController.java  # Temporary test endpoints
│   └── exception/
│       └── GlobalExceptionHandler.java  # @RestControllerAdvice
│
└── seeder/
    └── DataSeeder.java              # CommandLineRunner — demo data
```

```
frontend/lib/
├── main.dart                        # MaterialApp entry point
├── models/
│   └── models.dart                  # UserModel, TokenModel, MarketplacePostModel
├── services/
│   └── api_service.dart             # All HTTP calls (static methods)
└── screens/
    └── marketplace_screen.dart      # 3-tab test UI with countdown timer
```

### Why this structure?

1. **Feature isolation** — The marketplace module owns its entity, repo, service, controller, scheduler, DTOs, and exception. Any feature team member can work in `marketplace/` without touching other code.
2. **Shared models/repos** — Entities like `User`, `Token`, `Meal` are used by many features, so they live in the shared `models/` and `repositories/` packages.
3. **Common utilities** — CORS, API response wrapper, and global exception handler are cross-cutting and reusable by all features.

---

## 3. Database Schema & Entity Models

### 3.1 Entity-Relationship Diagram (Textual)

```
halls (1) ──── (N) users (1) ──── (1) wallets
                     │                    
                     │ (1)                
                     │                    
                (N) tokens (N) ──── (1) meals
                     │                    │
                     │                    └── belongs to one hall
            (1) marketplace_posts
                     │
            (1) token_transactions
```

### 3.2 `halls` table — `Hall.java`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT | PK, auto-increment | Primary key |
| `name` | VARCHAR | UNIQUE, NOT NULL | Hall name (e.g., "Shaheed Abdur Rab Hall") |

**Annotations**: `@Entity`, `@Table(name = "halls")`, `@Id @GeneratedValue(IDENTITY)`, `@Column(unique = true, nullable = false)`.  
**Lombok**: `@Data`, `@NoArgsConstructor`, `@AllArgsConstructor`, `@Builder`.

### 3.3 `users` table — `User.java`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT | PK, auto-increment | Primary key |
| `email` | VARCHAR | UNIQUE, NOT NULL | Student email |
| `password` | VARCHAR | NOT NULL | BCrypt hash (placeholder for now) |
| `name` | VARCHAR | NOT NULL | Display name |
| `hall_id` | BIGINT | FK → halls(id), NOT NULL | Which hall the student belongs to |
| `is_verified` | BOOLEAN | default false | Email verification flag |
| `role` | VARCHAR (ENUM) | NOT NULL | Stored as STRING: STUDENT, MEAL_MANAGER, or DINING_MANAGER |

**Relationships**: `@ManyToOne(LAZY)` to `Hall`.

### 3.4 `wallets` table — `Wallet.java`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT | PK (shared with user) | Same value as the linked user's ID |
| `balance` | DOUBLE | NOT NULL, default 0.0 | Coin balance |

**Relationships**: `@OneToOne(LAZY)` to `User` via `@MapsId` — the wallet's primary key IS the user's primary key. This creates a true 1:1 relationship at the database level.

**Helper methods**:
- `deduct(double amount)`: Reduces balance. Throws `IllegalStateException("Insufficient balance")` if balance < amount.
- `credit(double amount)`: Increases balance.

### 3.5 `student_infos` table — `StudentInfo.java`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT | PK (shared with user) | Via `@MapsId` |
| `roll` | VARCHAR | — | Student roll number |
| `room_no` | VARCHAR | — | Room number |
| `phone_no` | VARCHAR | — | Phone number |

**Relationships**: `@OneToOne(LAZY)` to `User` via `@MapsId`.

### 3.6 `meals` table — `Meal.java`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT | PK, auto-increment | Primary key |
| `hall_id` | BIGINT | FK → halls(id), NOT NULL | Which hall this meal belongs to |
| `meal_date` | DATE | NOT NULL | The date of the meal |
| `meal_type` | VARCHAR (ENUM) | NOT NULL | LUNCH or DINNER |
| `menu` | TEXT | — | Meal menu description |
| `price` | DOUBLE | NOT NULL | Cost in coins |
| `purchase_deadline` | DATETIME | — | Deadline for buying this meal's token |

**Relationships**: `@ManyToOne(LAZY)` to `Hall`.

### 3.7 `tokens` table — `Token.java`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT | PK, auto-increment | Primary key |
| `meal_id` | BIGINT | FK → meals(id), NOT NULL | Which meal this token is for |
| `owner_id` | BIGINT | FK → users(id), NOT NULL | Current owner (changes on marketplace transfer) |
| `status` | VARCHAR (ENUM) | NOT NULL | AVAILABLE, IN_QUEUE, USED, or LISTED |
| `created_at` | DATETIME | NOT NULL, non-updatable | Set via `@PrePersist` |
| `used_at` | DATETIME | nullable | Set when token is used (QR scan) |

**Unique Constraint**: `(owner_id, meal_id)` — A student can own at most one token per meal.

**`@PrePersist` callback**: Automatically sets `createdAt = LocalDateTime.now()` and `status = AVAILABLE` if not already specified when the entity is first persisted.

**Relationships**: `@ManyToOne(LAZY)` to `Meal`, `@ManyToOne(LAZY)` to `User`.

### 3.8 `coin_transactions` table — `CoinTransaction.java`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT | PK, auto-increment | Primary key |
| `sender_id` | BIGINT | FK → users(id), nullable | Null for TOPUP |
| `receiver_id` | BIGINT | FK → users(id), nullable | — |
| `amount` | DOUBLE | NOT NULL | Transaction amount |
| `type` | VARCHAR (ENUM) | NOT NULL | TOPUP or TRANSACTION |
| `created_at` | DATETIME | NOT NULL, non-updatable | Set via `@PrePersist` |

### 3.9 `token_transactions` table — `TokenTransaction.java`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT | PK, auto-increment | Primary key |
| `sender_id` | BIGINT | FK → users(id), NOT NULL | Previous owner |
| `receiver_id` | BIGINT | FK → users(id), NOT NULL | New owner |
| `token_id` | BIGINT | FK → tokens(id), NOT NULL | The transferred token |
| `created_at` | DATETIME | NOT NULL, non-updatable | Set via `@PrePersist` |

This record is created when the marketplace confirms a transfer — it's the audit trail.

---

## 4. Enums

### `Role` — `models/enums/Role.java`
```
STUDENT          → Regular hall resident who buys/sells tokens
MEAL_MANAGER     → Staff who manages meals for a hall
DINING_MANAGER   → Admin who oversees dining operations
```

### `MealType` — `models/enums/MealType.java`
```
LUNCH            → Midday meal
DINNER           → Evening meal
```

### `TokenStatus` — `models/enums/TokenStatus.java`
```
AVAILABLE        → Token is in the student's inventory, ready to use or sell
IN_QUEUE         → Token is being processed for QR validation (future feature)
USED             → Already used (scanned at dining hall)
LISTED           → Currently posted on the marketplace for sale
```

### `TransactionType` — `models/enums/TransactionType.java`

| Value | Meaning |
|-------|--------|
| `TOPUP` | Payment done outside the app (e.g., via bKash) — no wallet deduction/credit |
| `TRANSACTION` | In-app credit transfer — buyer's wallet deducted, seller's wallet credited |
```
TOPUP            → External payment (no wallet changes, just token transfer)
TRANSACTION      → Credit transfer (buyer wallet deducted, seller wallet credited)
```

Used in two contexts:
1. **CoinTransaction record** — `type` field records whether it was a wallet top-up or a marketplace credit transfer
2. **MarketplacePost.paymentType** — buyer selects payment method when clicking "Buy" (TRANSACTION for credit transfer, TOPUP for external payment)

### `MarketplacePostStatus` — `models/enums/MarketplacePostStatus.java`
```
OPEN             → Listing is visible, any eligible buyer can request
PENDING          → A buyer has requested; seller has 15 minutes to confirm
COMPLETED        → Token successfully transferred to buyer
```

---

## 5. Repositories

All repositories extend `JpaRepository<T, Long>`, giving them free CRUD: `save()`, `findById()`, `findAll()`, `delete()`, `count()`, etc.

### `HallRepository`
No custom methods. Used only for basic CRUD and existence checks in the seeder.

### `UserRepository`
| Method | Query | Purpose |
|--------|-------|---------|
| `findByEmail(String email)` | Derived query | Used by auth (future) to look up users during login |
| `existsByEmail(String email)` | Derived query | Check if email is already registered |

### `WalletRepository`
No custom methods. Used for `save()` during seeding and `findById()` for balance operations.

### `MealRepository`
| Method | Query | Purpose |
|--------|-------|---------|
| `findByHallIdAndMealDateAndMealType(Long, LocalDate, MealType)` | Derived query | Look up a specific meal by hall + date + type |

### `TokenRepository`
| Method | Query | Purpose |
|--------|-------|---------|
| `findByOwnerId(Long ownerId)` | Derived query | Get all tokens owned by a user (used by TestHelperController) |
| `findByOwnerIdAndStatus(Long, TokenStatus)` | Derived query | Get tokens with a specific status (e.g., AVAILABLE only) |
| `existsByOwnerIdAndMealId(Long, Long)` | Derived query | **Critical for marketplace**: prevents buying a token for a meal you already own |

### `TokenTransactionRepository`
| Method | Query | Purpose |
|--------|-------|---------|
| `findBySenderIdOrReceiverId(Long, Long)` | Derived query | Get all transactions involving a user (audit trail) |

### `CoinTransactionRepository`
| Method | Query | Purpose |
|--------|-------|---------|
| `findBySenderIdOrReceiverId(Long, Long)` | Derived query | Get all coin transactions involving a user (wallet audit trail) |

---

## 6. Marketplace Module — Deep Dive

### 6.1 MarketplacePost Entity

**File**: `marketplace/MarketplacePost.java`  
**Table**: `marketplace_posts`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT | PK, auto-increment | Post ID |
| `token_id` | BIGINT | FK → tokens(id), NOT NULL | The token being sold |
| `seller_id` | BIGINT | FK → users(id), NOT NULL | Who listed the token |
| `buyer_id` | BIGINT | FK → users(id), nullable | Who requested to buy (null when OPEN) |
| `status` | VARCHAR (ENUM) | NOT NULL | OPEN, PENDING, or COMPLETED |
| `payment_type` | VARCHAR (ENUM) | nullable | TRANSACTION or TOPUP — buyer's chosen payment method (null when OPEN) |
| `created_at` | DATETIME | NOT NULL, non-updatable | When the post was created |
| `buyer_requested_at` | DATETIME | nullable | When a buyer sent a buy request (starts 15-min timer) |

**`@PrePersist`**: Sets `createdAt = LocalDateTime.now()` and `status = OPEN` if not already set.

**Relationships**:
- `@ManyToOne(LAZY)` → `Token` — the token being sold
- `@ManyToOne(LAZY)` → `User seller` — who created the listing
- `@ManyToOne(LAZY)` → `User buyer` — who requested to buy (nullable)
- `@Enumerated(STRING)` → `TransactionType paymentType` — buyer's payment choice (nullable, cleared on rollback)

### 6.2 Marketplace Repository & Queries

**File**: `marketplace/MarketplaceRepository.java`

All custom queries use `JOIN FETCH` to eagerly load related entities in a single SQL query (avoids N+1 problem):

| Method | JPQL Query Logic | Returns | Purpose |
|--------|-----------------|---------|---------|
| `findByStatusAndHallId(status, hallId)` | `SELECT p FROM MarketplacePost p JOIN FETCH p.token t JOIN FETCH t.meal m JOIN FETCH p.seller s JOIN FETCH s.hall WHERE p.status = :status AND s.hall.id = :hallId ORDER BY p.createdAt DESC` | `List<MarketplacePost>` | **Browse**: Get all open listings for a specific hall. Joins through `post → seller → hall` to filter by hall. |
| `findBySellerIdAndStatusIn(sellerId, statuses)` | Similar JOIN FETCH, `WHERE p.seller.id = :sellerId AND p.status IN :statuses` | `List<MarketplacePost>` | **My Listings**: Get a seller's active listings (both OPEN and PENDING). |
| `findByBuyerIdAndStatus(buyerId, status)` | Similar JOIN FETCH, `WHERE p.buyer.id = :buyerId AND p.status = :status` | `List<MarketplacePost>` | **My Purchases**: Get posts where this user is the pending buyer. |
| `findTimedOutPendingPosts(status, cutoff)` | `WHERE p.status = :status AND p.buyerRequestedAt < :cutoff` | `List<MarketplacePost>` | **Scheduler**: Find posts that have been PENDING for more than 15 minutes. |
| `existsByTokenIdAndStatusIn(tokenId, statuses)` | `SELECT CASE WHEN COUNT(p) > 0 ...` | `boolean` | **Guard**: Check if a token already has an active listing before creating a new one. |
| `findFirstByTokenIdAndStatusIn(tokenId, statuses)` | Wraps in `Optional<>` | `Optional<MarketplacePost>` | **Lookup**: Get the active marketplace post for a specific token. |

### 6.3 Marketplace Service — Every Method Explained

**File**: `marketplace/MarketplaceService.java` (473 lines)

**Class-level annotations**: `@Service` (Spring bean), `@RequiredArgsConstructor` (constructor DI), `@Slf4j` (logging).

**Injectable dependencies** (via constructor):
- `MarketplaceRepository` — marketplace posts CRUD + custom queries
- `TokenRepository` — token status updates + ownership transfer
- `UserRepository` — look up users for validation
- `TokenTransactionRepository` — record token transfer audit trail
- `WalletRepository` — deduct buyer / credit seller wallet balances
- `CoinTransactionRepository` — record coin transaction audit trail

**Constants**:
- `PENDING_TIMEOUT_MINUTES = 15` — how long a buyer's request stays alive

---

#### `createSellPost(Long sellerId, Long tokenId)` → `MarketplacePostResponse`

**Purpose**: List a token for sale on the marketplace.

**Annotations**: `@Transactional` (read-write, rolls back on exception)

**Logic flow**:
1. Look up seller and token (throw `MarketplaceException` if not found)
2. **Validation — Ownership**: `token.getOwner().getId().equals(sellerId)` → reject if caller doesn't own the token
3. **Validation — Status**: `token.getStatus() != TokenStatus.AVAILABLE` → reject if token is already USED, IN_QUEUE, or LISTED
4. **Validation — No duplicate listing**: `marketplaceRepository.existsByTokenIdAndStatusIn(tokenId, [OPEN, PENDING])` → reject if token already has an active listing
5. **Side effect #1**: `token.setStatus(TokenStatus.LISTED)` → mark the token so it can't be used or sold again while listed
6. **Side effect #2**: Create and save a new `MarketplacePost` with status=OPEN, seller set, buyer=null
7. Log the action and return the DTO response

**Why `@Transactional`**: Steps 5 and 6 must be atomic. If the post creation fails, the token status change rolls back too.

---

#### `getOpenPosts(Long hallId)` → `List<MarketplacePostResponse>`

**Purpose**: Browse all available-for-purchase listings in a specific hall.

**Annotations**: `@Transactional(readOnly = true)` (optimization hint: no write locks)

**Logic flow**:
1. Call `marketplaceRepository.findByStatusAndHallId(OPEN, hallId)` — gets all posts where status is OPEN and the seller belongs to the given hall
2. Map each `MarketplacePost` → `MarketplacePostResponse` via `toResponse()`
3. Return the list

**Why filter by hall**: Business rule — students should only see listings from their own hall.

---

#### `getPostById(Long postId)` → `MarketplacePostResponse`

**Purpose**: Get details of a single marketplace post.

**Logic**: Find post by ID or throw exception, convert to DTO.

---

#### `sendBuyRequest(Long postId, Long buyerId, TransactionType paymentType)` → `MarketplacePostResponse`

**Purpose**: A buyer clicks "Buy" on a listing and chooses a payment method. This doesn't transfer the token yet — it puts the post into a 15-minute pending window.

**Annotations**: `@Transactional`

**Parameters**:
- `postId` — the marketplace listing
- `buyerId` — the buyer's user ID
- `paymentType` — `TRANSACTION` (credit transfer) or `TOPUP` (external payment)

**Logic flow**:
1. Load the post and buyer
2. **Validation — Status**: Post must be `OPEN`. If it's already `PENDING` or `COMPLETED`, reject with "no longer available"
3. **Validation — Self-buy**: `post.getSeller().getId().equals(buyerId)` → you can't buy your own listing
4. **Validation — Hall match**: `buyer.getHall().getId().equals(post.getSeller().getHall().getId())` → cross-hall purchases are blocked
5. **Validation — Duplicate token**: `tokenRepository.existsByOwnerIdAndMealId(buyerId, mealId)` → if the buyer already owns a token for this meal (via normal purchase), reject
6. **Side effect**: Set `post.buyer = buyer`, `post.status = PENDING`, `post.paymentType = paymentType`, `post.buyerRequestedAt = now()`
7. Save and return

**The 15-minute window**: Once `buyerRequestedAt` is set, the scheduler checks every 60 seconds. If `now() - buyerRequestedAt > 15 minutes`, the post is rolled back to OPEN automatically.

---

#### `confirmTransfer(Long postId, Long sellerId)` → `MarketplacePostResponse`

**Purpose**: Seller confirms the transfer. This is the ATOMIC operation that actually moves the token. Credit transfer behavior depends on the buyer's chosen `paymentType`.

**Annotations**: `@Transactional` (CRITICAL — ensures all DB writes succeed or all fail)

**Logic flow**:
1. Load the post
2. **Validation — Status**: Must be `PENDING`
3. **Validation — Authorization**: Only the seller can confirm
4. **Double-check**: `tokenRepository.existsByOwnerIdAndMealId(buyer.id, mealId)` — race condition guard. If the buyer somehow acquired a token for this meal between the buy-request and now, the request is rolled back (buyer, paymentType, buyerRequestedAt cleared) and an error is thrown
5. **CONDITIONAL CREDIT TRANSFER** (only if `paymentType == TRANSACTION`):
   - Deduct meal price from buyer's wallet (throws if insufficient balance)
   - Credit meal price to seller's wallet
   - Create `CoinTransaction` record (sender=buyer, receiver=seller, type=TRANSACTION)
   - If `paymentType == TOPUP`: skip wallet operations entirely (payment handled outside app)
6. **TOKEN TRANSFER**: `token.setOwner(buyer)` + `token.setStatus(AVAILABLE)` — the token now belongs to the buyer and is usable
7. **COMPLETE POST**: `post.setStatus(COMPLETED)` — the listing is finalized
8. **AUDIT TRAIL**: Create a `TokenTransaction` record with `sender=seller, receiver=buyer, token=token`
9. Log and return

**Why @Transactional matters here**: If any step fails, all preceding steps roll back. The token stays with the seller, wallets are unchanged, and the post stays PENDING. No money/tokens are lost.

**Payment type behavior summary**:
| Payment Type | Wallet Changes | CoinTransaction Created | Token Transfer |
|-------------|---------------|------------------------|----------------|
| `TRANSACTION` | Buyer deducted, Seller credited | Yes | Yes |
| `TOPUP` | None (external payment) | No | Yes |

---

#### `rejectBuyRequest(Long postId, Long sellerId)` → `MarketplacePostResponse`

**Purpose**: Seller sees a pending buy request and decides to reject it.

**Annotations**: `@Transactional`

**Logic flow**:
1. Load the post
2. **Validation**: Must be `PENDING`
3. **Authorization**: Only the seller can reject
4. **Rollback**: Set `buyer = null`, `status = OPEN`, `paymentType = null`, `buyerRequestedAt = null`
5. Save and return

**After rejection**: The listing goes back to being browsable. Any student (including the rejected buyer) can send a new buy request.

---

#### `cancelBuyRequest(Long postId, Long buyerId)` → `MarketplacePostResponse`

**Purpose**: Buyer changes their mind and cancels their pending request.

**Annotations**: `@Transactional`

**Logic flow**: Identical to `rejectBuyRequest` but validated with `post.getBuyer().getId().equals(buyerId)` — only the buyer can cancel their own request. Also clears `paymentType`.

---

#### `cancelListing(Long postId, Long sellerId)` → `void`

**Purpose**: Seller removes their listing from the marketplace.

**Annotations**: `@Transactional`

**Logic flow**:
1. Load the post
2. **Validation**: Must be `OPEN` — can't cancel if a buyer is pending (they'd have to wait for timeout or reject first)
3. **Authorization**: Only the seller can cancel
4. **Restore token**: `token.setStatus(AVAILABLE)` — the token goes back to the seller's inventory
5. **Delete post**: `marketplaceRepository.delete(post)` — the listing is removed entirely (not soft-deleted)

---

#### `expireTimedOutRequests()` → `int`

**Purpose**: Called by the scheduler every 60 seconds to clean up stale PENDING posts.

**Annotations**: `@Transactional`

**Logic flow**:
1. Calculate cutoff: `LocalDateTime.now().minusMinutes(15)`
2. Query: `marketplaceRepository.findTimedOutPendingPosts(PENDING, cutoff)` — finds all PENDING posts where `buyerRequestedAt < cutoff`
3. For each timed-out post: set `buyer = null`, `status = OPEN`, `paymentType = null`, `buyerRequestedAt = null`
4. Save each and log
5. Return count of expired posts

**Effect**: Auto-protects sellers from ghost buyers who request but never follow through.

---

#### `getMyListings(Long sellerId)` → `List<MarketplacePostResponse>`

**Purpose**: Seller's dashboard — show their active listings (both OPEN waiting for buyers, and PENDING waiting for confirmation).

**Logic**: Query with status IN [OPEN, PENDING], filtered by seller ID.

---

#### `getMyPurchases(Long buyerId)` → `List<MarketplacePostResponse>`

**Purpose**: Buyer's dashboard — show their pending buy requests.

**Logic**: Query with status = PENDING, filtered by buyer ID.

---

#### `isTokenListed(Long tokenId)` → `boolean`

**Purpose**: Cross-module utility. Other features (e.g., QR validation) can check if a token is currently listed on the marketplace before allowing operations.

**Logic**: `existsByTokenIdAndStatusIn(tokenId, [OPEN, PENDING])`.

---

#### `getActivePostForToken(Long tokenId)` → `MarketplacePostResponse | null`

**Purpose**: Cross-module utility. Find the active marketplace post for a given token, if any.

**Logic**: `findFirstByTokenIdAndStatusIn(tokenId, [OPEN, PENDING])`, map to DTO or return null.

---

#### Private Helper Methods

| Method | Purpose |
|--------|---------|
| `findUserOrThrow(Long userId)` | `userRepository.findById()` → throws `MarketplaceException("User not found: " + userId)` |
| `findTokenOrThrow(Long tokenId)` | `tokenRepository.findById()` → throws `MarketplaceException("Token not found: " + tokenId)` |
| `findPostOrThrow(Long postId)` | `marketplaceRepository.findById()` → throws `MarketplaceException("Marketplace post not found: " + postId)` |
| `toResponse(MarketplacePost post)` | Converts entity → `MarketplacePostResponse` DTO (extracts token meal details, seller/buyer info, timestamps) |

### 6.4 Marketplace Controller — Every Endpoint

**File**: `marketplace/MarketplaceController.java`  
**Base path**: `/api/v1/marketplace`  
**Class annotation**: `@RestController`, `@RequestMapping("/api/v1/marketplace")`, `@RequiredArgsConstructor`

Every endpoint extracts `userId` from the `X-User-Id` header and wraps responses in `ApiResponse<T>`.

---

| # | Method | Path | Auth Header | Request Body | Calls | Response |
|---|--------|------|-------------|--------------|-------|----------|
| 1 | `GET` | `/posts` | X-User-Id | — | `service.getOpenPosts(user.hall.id)` | List of open posts for user's hall |
| 2 | `GET` | `/my-tokens` | X-User-Id | — | `service.getMyAvailableTokens(userId)` | User's available tokens (can sell) |
| 3 | `POST` | `/sell` | X-User-Id | `{ "tokenId": 5 }` | `service.createSellPost(userId, tokenId)` | Created post |
| 4 | `DELETE` | `/{id}` | X-User-Id | — | `service.cancelListing(id, userId)` | Success message |
| 5 | `POST` | `/buy` | X-User-Id | `{ "postId": 1, "paymentType": "TRANSACTION" }` | `service.sendBuyRequest(postId, userId, paymentType)` | Updated post (PENDING) |
| 6 | `POST` | `/purchases/{id}/cancel` | X-User-Id | — | `service.cancelBuyRequest(id, userId)` | Updated post (OPEN) |
| 7 | `POST` | `/listings/{id}/reject` | X-User-Id | — | `service.rejectBuyRequest(id, userId)` | Updated post (OPEN) |
| 8 | `POST` | `/listings/{id}/confirm` | X-User-Id | — | `service.confirmTransfer(id, userId)` | Updated post (COMPLETED) |
| 9 | `GET` | `/my-listings` | X-User-Id | — | `service.getMyListings(userId)` | Seller's active listings |
| 10 | `GET` | `/my-purchases` | X-User-Id | — | `service.getMyPurchases(userId)` | Buyer's pending purchases |

**How `X-User-Id` is resolved in `browseMarketplace` (endpoint #1)**:
```java
Long userId = Long.parseLong(userIdHeader);
User user = userRepository.findById(userId).orElseThrow(...);
Long hallId = user.getHall().getId();
return ApiResponse.success(service.getOpenPosts(hallId), "Listings fetched");
```
The controller resolves the user and passes only the `hallId` to the service. This ensures the service itself is agnostic about how auth works — it just receives a hall ID.

### 6.5 Marketplace Scheduler

**File**: `marketplace/MarketplaceScheduler.java`

```java
@Component
@RequiredArgsConstructor
@Slf4j
public class MarketplaceScheduler {
    private final MarketplaceService marketplaceService;

    @Scheduled(fixedRate = 60000) // every 60 seconds
    public void expirePendingRequests() {
        int expired = marketplaceService.expireTimedOutRequests();
        if (expired > 0) {
            log.info("Scheduler: expired {} timed-out marketplace requests", expired);
        }
    }
}
```

- **`fixedRate = 60000`**: Runs every 60,000 milliseconds (1 minute)
- **`@EnableScheduling`**: Enabled on `BackendApplication.java` — required for `@Scheduled` to work
- **Delegates to service**: The scheduler is a thin wrapper. Business logic stays in the service.

### 6.6 DTOs

#### `SellRequest` — Input DTO

```java
@Data
public class SellRequest {
    private Long tokenId;
}
```
Deserialized from the JSON body of `POST /sell`. Only contains the token ID — the seller is identified via the header.

#### `BuyRequest` — Input DTO

```java
@Data
public class BuyRequest {
    private Long postId;
    private String paymentType;  // "TRANSACTION" or "TOPUP"
}
```
Deserialized from the JSON body of `POST /buy`. Contains the post ID and the buyer's chosen payment method. The controller converts the `paymentType` string to a `TransactionType` enum.

#### `MarketplacePostResponse` — Output DTO

```java
@Data @Builder
public class MarketplacePostResponse {
    private Long id;
    private Long tokenId;
    private String mealType;      // "LUNCH" or "DINNER"
    private String mealDate;      // "2025-01-15"
    private String mealMenu;      // "Rice, Chicken Curry, ..."
    private Double mealPrice;     // 60.0
    private Long sellerId;
    private String sellerName;
    private Long buyerId;         // null if OPEN
    private String buyerName;     // null if OPEN
    private String status;        // "OPEN", "PENDING", or "COMPLETED"
    private String paymentType;   // "TRANSACTION", "TOPUP", or null (if OPEN)
    private String createdAt;     // ISO datetime string
    private String buyerRequestedAt; // null if no buyer request yet
}
```

This DTO **flattens** the entity graph. Instead of returning nested objects (token → meal → hall), it extracts the relevant fields into a flat structure. This makes the API response simple for the frontend.

### 6.7 Custom Exception

```java
public class MarketplaceException extends RuntimeException {
    public MarketplaceException(String message) {
        super(message);
    }
}
```

Caught by `GlobalExceptionHandler` which returns:
```json
{
  "success": false,
  "message": "You do not own this token",
  "data": null
}
```
with HTTP 400 Bad Request.

---

## 7. Common Module

### 7.1 `ApiResponse<T>` — Generic Response Wrapper

Every API response is wrapped in this structure:

```java
@Data @Builder
public class ApiResponse<T> {
    private boolean success;
    private String message;
    private T data;

    public static <T> ApiResponse<T> success(T data, String message) { ... }
    public static <T> ApiResponse<T> error(String message) { ... }
}
```
Ensures consistent JSON structure across all endpoints.

### 7.2 `CorsConfig` — CORS Configuration

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*");
    }
}
```
Required for Flutter web or any frontend running on a different port/origin.

### 7.3 `GlobalExceptionHandler`

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(MarketplaceException.class)   → 400 Bad Request
    @ExceptionHandler(IllegalStateException.class)  → 400 Bad Request
    @ExceptionHandler(Exception.class)              → 500 Internal Server Error
}
```
Each handler returns `ApiResponse.error(message)` so the frontend always gets a parseable JSON response, even on errors.

### 7.4 `TestHelperController`

Temporary endpoints for testing without a full auth flow:

| Endpoint | Purpose |
|----------|---------|
| `GET /api/v1/test/users` | Returns all users as `UserResponse` DTOs |
| `GET /api/v1/test/tokens` | Returns all tokens for the user specified in `X-User-Id` header, converted to `TokenResponse` DTOs |

These will be removed once proper auth and user/token management endpoints exist.

---

## 8. Data Seeder

**File**: `seeder/DataSeeder.java`

Implements `CommandLineRunner` — runs automatically on application startup.

**Guard**: `if (hallRepository.count() > 0) return;` — only seeds on first run. Subsequent restarts skip seeding.

### Seeded Data

| Entity | Records | Details |
|--------|---------|---------|
| Halls | 2 | "Shaheed Abdur Rab Hall" (Hall 1), "Shaheed Shah Paran Hall" (Hall 2) |
| Users | 4 | Rumi, Karim, Tanvir → Hall 1; Sakib → Hall 2 |
| Wallets | 4 | Rumi: ৳500, Karim: ৳300, Tanvir: ৳200, Sakib: ৳400 |
| Meals | 2 | Tomorrow's LUNCH + DINNER for Hall 1 |
| Tokens | 3 | Rumi: lunch + dinner; Karim: lunch; Tanvir: none; Sakib: none |

### Test Scenarios This Enables

1. **Sell flow**: Rumi lists his lunch token → Tanvir buys it
2. **Buy flow**: Tanvir (no tokens) requests to buy from the browse tab
3. **Hall isolation**: Sakib (Hall 2) tries to buy from Hall 1 → gets rejected
4. **Duplicate guard**: Karim (has lunch token) tries to buy another lunch token → gets rejected
5. **Self-buy guard**: Rumi tries to buy his own listing → gets rejected
6. **Reject flow**: Seller sees pending request → clicks reject → listing goes back to OPEN
7. **Cancel flow**: Buyer cancels their own pending request
8. **Timeout flow**: 15-minute scheduler auto-rollback

---

## 9. Flutter Frontend — Test UI

### 9.1 Models (`models/models.dart`)

Three Dart model classes, each with a `fromJson` factory constructor:

#### `UserModel`
```dart
fields: id, name, email, hallId, hallName, role
toString(): "$name (Hall: $hallName)"  // shown in dropdown
```

#### `TokenModel`
```dart
fields: id, mealId, mealType, mealDate, menu, price, status
```

#### `MarketplacePostModel`
```dart
fields: id, tokenId, mealType, mealDate, mealMenu, mealPrice,
        sellerId, sellerName, buyerId, buyerName, status,
        createdAt, buyerRequestedAt
```

### 9.2 API Service (`services/api_service.dart`)

Static class with all HTTP calls. Base URL: `http://localhost:8080/api/v1`

Every method:
1. Makes an HTTP request with `_headers(userId)` → `{ 'Content-Type': 'application/json', 'X-User-Id': userId }`
2. Decodes the JSON body
3. Checks `body['success'] == true` → throws Exception if false
4. Parses `body['data']` into model objects

| Method | HTTP | URL | Returns |
|--------|------|-----|---------|
| `getUsers()` | GET | `/test/users` | `List<UserModel>` |
| `getMyTokens(userId)` | GET | `/marketplace/my-tokens` | `List<TokenModel>` |
| `getOpenPosts(userId)` | GET | `/marketplace/posts` | `List<MarketplacePostModel>` |
| `sellToken(userId, tokenId)` | POST | `/marketplace/sell` | `MarketplacePostModel` |
| `sendBuyRequest(userId, postId, paymentType)` | POST | `/marketplace/buy` | `MarketplacePostModel` |
| `confirmTransfer(userId, postId)` | POST | `/marketplace/listings/{id}/confirm` | `MarketplacePostModel` |
| `cancelBuyRequest(userId, postId)` | POST | `/marketplace/purchases/{id}/cancel` | `MarketplacePostModel` |
| `rejectBuyRequest(userId, postId)` | POST | `/marketplace/listings/{id}/reject` | `MarketplacePostModel` |
| `cancelListing(userId, postId)` | DELETE | `/marketplace/{id}` | `void` |
| `getMyListings(userId)` | GET | `/marketplace/my-listings` | `List<MarketplacePostModel>` |
| `getMyPurchases(userId)` | GET | `/marketplace/my-purchases` | `List<MarketplacePostModel>` |

### 9.3 Marketplace Screen (`screens/marketplace_screen.dart`)

**555 lines** — a `StatefulWidget` with `SingleTickerProviderStateMixin` for TabBar animation.

#### State variables
```dart
List<UserModel> users            // All users from the test endpoint
UserModel? selectedUser          // Currently selected user (dropdown)
List<MarketplacePostModel> openPosts    // Browse tab data
List<TokenModel> myTokens        // My Tokens tab data
List<MarketplacePostModel> myListings   // Activity tab — seller section
List<MarketplacePostModel> myPurchases  // Activity tab — buyer section
bool loading                     // Show progress indicator
Timer? _countdownTimer           // Ticks every 1 second for countdown display
```

#### Lifecycle

**`initState()`**:
1. Creates a `TabController` with 3 tabs
2. Calls `_loadUsers()` to fetch all users from the API
3. Starts `Timer.periodic(Duration(seconds: 1))` → calls `setState(() {})` which rebuilds the widget tree every second, updating all countdown timers

**`dispose()`**:
- Cancels the countdown timer
- Disposes the tab controller

#### Data loading

**`_loadUsers()`**: Fetches all users → sets first user as `selectedUser` → calls `_refreshAll()`

**`_refreshAll()`**: Fetches 4 API calls in parallel using `Future.wait()`:
1. `getOpenPosts(uid)` → populates browse tab
2. `getMyTokens(uid)` → populates my tokens tab
3. `getMyListings(uid)` → populates activity tab (seller section)
4. `getMyPurchases(uid)` → populates activity tab (buyer section)

#### Action methods

| Method | Calls | Success message |
|--------|-------|-----------------|
| `_sellToken(token)` | `ApiService.sellToken()` | "Token listed for sale!" |
| `_buyRequest(post)` | `ApiService.sendBuyRequest()` | "Buy request sent!" |
| `_confirmTransfer(post)` | `ApiService.confirmTransfer()` | "Token transferred!" |
| `_cancelRequest(post)` | `ApiService.cancelBuyRequest()` | "Buy request cancelled." |
| `_cancelListing(post)` | `ApiService.cancelListing()` | "Listing cancelled." |
| `_rejectRequest(post)` | `ApiService.rejectBuyRequest()` | "Buy request rejected." |

Each action catches errors and shows a red SnackBar. On success, shows a green SnackBar and calls `_refreshAll()` to update all tabs.

#### Countdown Timer Logic

**`_remainingTime(String? buyerRequestedAt)`**:
```dart
1. Parse the ISO string to DateTime
2. Add 15 minutes to get expiry time
3. Calculate remaining = expiry - now
4. Return Duration.zero if expired, otherwise the remaining Duration
```

**`_formatDuration(Duration d)`**:
```dart
Format as "MM:SS" → e.g., "14:32", "00:05"
```

Since the 1-second timer calls `setState` every tick, Dart rebuilds the widget tree and `_remainingTime()` is recalculated, giving a live ticking countdown.

#### UI Structure — 3 Tabs

**Tab 1 — Browse**:
- Shows all OPEN listings in the user's hall
- Each card shows: meal icon (lunch=orange, dinner=indigo), meal type, date, menu, price, seller name
- If the listing is yours: shows a "Yours" chip
- Otherwise: shows a "Buy" button

**Tab 2 — My Tokens**:
- Shows all tokens owned by the current user
- If status is AVAILABLE: shows a "Sell" button
- Otherwise: shows a status chip with appropriate color

**Tab 3 — Activity** (scrollable list with two sections):
- **My Listings**: Active listings where you are the seller
  - OPEN listings: show "Cancel Listing" button
  - PENDING listings: show buyer name, countdown timer, "Confirm" button (green), "Reject" button (red)
- **My Purchase Requests**: Pending listings where you are the buyer
  - Shows seller name, countdown timer in a colored container, "Cancel Request" button

**User Selector** (top bar):
- Dropdown to switch between seeded users (Rumi, Karim, Tanvir, Sakib)
- Changing the user immediately refreshes all data
- This simulates logging in as different users for testing

---

## 10. Business Rules & Validation Summary

| Rule | Enforced In | Error Message |
|------|------------|---------------|
| Can only sell tokens you own | `createSellPost()` | "You do not own this token" |
| Token must be AVAILABLE to sell | `createSellPost()` | "Token is not available for listing. Current status: X" |
| No duplicate listings for same token | `createSellPost()` | "This token already has an active marketplace listing" |
| Can't buy your own listing | `sendBuyRequest()` | "You cannot buy your own listing" |
| Can only buy from your own hall | `sendBuyRequest()` | "You can only buy tokens from your own hall" |
| Can't buy if you already own that meal's token | `sendBuyRequest()` | "You already own a token for this meal" |
| Post must be OPEN to receive buy requests | `sendBuyRequest()` | "This listing is no longer available. Status: X" |
| Buyer must choose payment type (TRANSACTION or TOPUP) | `buyRequest()` controller | Invalid enum throws error |
| Only seller can confirm transfer | `confirmTransfer()` | "Only the seller can confirm the transfer" |
| Buyer must have sufficient wallet balance (TRANSACTION only) | `confirmTransfer()` | "Buyer has insufficient balance. Required: X" |
| Only seller can reject buy request | `rejectBuyRequest()` | "Only the seller can reject the buy request" |
| Only buyer can cancel buy request | `cancelBuyRequest()` | "Only the buyer can cancel the request" |
| Can only cancel OPEN listings | `cancelListing()` | "Cannot cancel listing with status: X" |
| Buyer double-own check at confirm-time | `confirmTransfer()` | "Buyer already owns a token for this meal" |
| 15-minute timeout auto-rollback | `expireTimedOutRequests()` | (automatic, no user-facing error) |

---

## 11. Complete Marketplace Flow

### Happy Path — Full Token Sale

```
SELLER (Rumi)                        SYSTEM                          BUYER (Tanvir)
    │                                   │                                │
    ├─ POST /sell {tokenId: 5}         │                                │
    │   → Token status: LISTED          │                                │
    │   → Post status: OPEN             │                                │
    │   ← 200 {post data}              │                                │
    │                                   │                                │
    │                                   │     GET /posts (browse) ─────┤
    │                                   │     ← 200 [list with post]    │
    │                                   │                                │
    │                                   │     POST /buy {postId,         │
    │                                   │       paymentType:"TRANSACTION"}│
    │                                   │     → Post status: PENDING     │
    │                                   │     → paymentType stored       │
    │                                   │     → 15-min timer starts      │
    │                                   │     ← 200 {post data}         │
    │                                   │                                │
    ├─ GET /my-listings                │                                │
    │   ← 200 [post with buyerName]    │                                │
    │                                   │                                │
    ├─ POST /listings/{id}/confirm     │                                │
    │   → If TRANSACTION:              │                                │
    │     Buyer wallet deducted         │                                │
    │     Seller wallet credited        │                                │
    │     CoinTransaction created       │                                │
    │   → If TOPUP: no wallet changes   │                                │
    │   → Token owner:  Rumi → Tanvir  │                                │
    │   → Token status: AVAILABLE       │                                │
    │   → Post status:  COMPLETED       │                                │
    │   → TokenTransaction created      │                                │
    │   ← 200 {post data}              │                                │
    │                                   │                                │
    │                                   │     GET /test/tokens  ────────┤
    │                                   │     ← 200 [now has the token] │
```

### Seller Reject Flow

```
BUYER sends buy request  →  Post = PENDING, paymentType stored
SELLER clicks Reject     →  Post = OPEN (buyer/paymentType/buyerRequestedAt cleared)
                            Listing visible again for other buyers
```

### Auto-Timeout Flow

```
BUYER sends buy request       →  Post = PENDING, paymentType stored, buyerRequestedAt = T
... 15 minutes pass ...
SCHEDULER runs (every 60s)    →  now() - T > 15 min → Post = OPEN
                                 buyer/paymentType/buyerRequestedAt cleared
```

### Cancel Listing Flow

```
SELLER lists token  →  Post = OPEN, Token = LISTED
SELLER cancels      →  Token = AVAILABLE, Post deleted
```

---

## 12. API Reference

### Base URL: `http://localhost:8080/api/v1`

### Marketplace Endpoints

#### `GET /marketplace/posts`
Browse open listings in your hall.
```
Headers: X-User-Id: 1
Response: { success: true, data: [...], message: "Listings fetched" }
```

#### `GET /marketplace/my-tokens`
Get your available tokens (can be listed for sale).
```
Headers: X-User-Id: 1
Response: { success: true, data: [...], message: "Your available tokens" }
```

#### `POST /marketplace/sell`
List a token for sale.
```
Headers: X-User-Id: 1
Body: { "tokenId": 5 }
Response: { success: true, data: { ... }, message: "Token listed for sale" }
```

#### `DELETE /marketplace/{id}`
Seller cancels their listing (must be OPEN).
```
Headers: X-User-Id: 1  (must be the seller, post must be OPEN)
Response: { success: true, data: null, message: "Listing cancelled" }
```

#### `POST /marketplace/buy`
Send a buy request with payment type.
```
Headers: X-User-Id: 3
Body: { "postId": 1, "paymentType": "TRANSACTION" }
       or { "postId": 1, "paymentType": "TOPUP" }
Response: { success: true, data: { ... }, message: "Buy request sent — seller has 15 min to confirm" }
```

#### `POST /marketplace/purchases/{id}/cancel`
Buyer cancels their pending request.
```
Headers: X-User-Id: 3  (must be the buyer)
Response: { success: true, data: { ... }, message: "Buy request cancelled" }
```

#### `POST /marketplace/listings/{id}/confirm`
Seller confirms transfer (atomic ownership swap + conditional credit transfer).
```
Headers: X-User-Id: 1  (must be the seller)
Response: { success: true, data: { ... }, message: "Token transferred successfully" }
```
If `paymentType` was `TRANSACTION`: buyer wallet deducted, seller wallet credited, CoinTransaction created.
If `paymentType` was `TOPUP`: only token transferred, no wallet changes.

#### `POST /marketplace/listings/{id}/reject`
Seller rejects buy request.
```
Headers: X-User-Id: 1  (must be the seller)
Response: { success: true, data: { ... }, message: "Buy request rejected" }
```

#### `GET /marketplace/my-listings`
Get seller's active listings.
```
Headers: X-User-Id: 1
Response: { success: true, data: [...], message: "..." }
```

#### `GET /marketplace/my-purchases`
Get buyer's pending purchases.
```
Headers: X-User-Id: 3
Response: { success: true, data: [...], message: "..." }
```

### Test Endpoints

#### `GET /test/users`
Returns all users.

#### `GET /test/tokens`
Returns all tokens for the user specified in `X-User-Id`.

---

## 13. Configuration

### `application.properties`

```properties
spring.application.name=backend
spring.datasource.url=jdbc:postgresql://localhost:5432/dsiApp
spring.datasource.username=aliazgorrumi
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
logging.level.dsi.ruet.backend=DEBUG
```

| Property | Purpose |
|----------|---------|
| `ddl-auto=update` | Hibernate auto-creates/updates tables on startup. **Not for production** — use migrations. |
| `show-sql=true` | Prints generated SQL to console. Useful for debugging queries. |
| `format_sql=true` | Pretty-prints the SQL. |
| `logging.level=DEBUG` | Shows detailed logs including marketplace service actions. |

### `pubspec.yaml` (Flutter)

Added dependency: `http: ^1.2.0` — for making HTTP requests to the backend.

---

## Appendix: State Machine Diagrams

### Token Status Lifecycle
```
                  ┌─────────────┐
                  │  AVAILABLE  │ ← initial state (purchase or marketplace receive)
                  └──────┬──────┘
                         │
              ┌──────────┼──────────┐
              ▼                     ▼
    ┌─────────────┐        ┌──────────┐
    │   LISTED    │        │ IN_QUEUE │ (future: QR scanning)
    │ (on market) │        └────┬─────┘
    └──────┬──────┘             │
           │                    ▼
           │              ┌─────────┐
           │              │  USED   │ (scanned at dining)
           │              └─────────┘
           │
           ▼
    ┌─────────────┐
    │  AVAILABLE  │ (transferred to buyer → new owner)
    └─────────────┘
```

### Marketplace Post Status Lifecycle
```
    ┌────────┐       buy request       ┌──────────┐      confirm       ┌───────────┐
    │  OPEN  │ ─────────────────────▶  │ PENDING  │ ──────────────── ▶ │ COMPLETED │
    └────────┘                         └──────────┘                    └───────────┘
        ▲                                  │  │
        │          reject/cancel/timeout   │  │
        └──────────────────────────────────┘  │
                                              │
                        cancel listing        │
                   (OPEN only → delete post)  │
```

---

*Document generated for the DSI RUET project. Last updated: Session 2 — Payment type selection, API endpoint renames, credit transfer, wallet integration.*
