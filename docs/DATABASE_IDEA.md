# Digital Dining Token Management System — Database Schema

## 1. Halls

Represents residential halls/dining halls.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Unique hall identifier |
| name | varchar(100) | unique, not null | Hall name |

---

## 2. Auth Users

Authentication table for login and role management.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | User ID |
| email | varchar(120) | unique, not null | Login email |
| password_hash | varchar(255) | not null | Hashed password |
| is_verified | boolean | default false | Email verification status |
| role | varchar(20) | not null | User role |
| created_at | timestamp | default now() | Account creation time |

**Allowed Roles:**
- `STUDENT`
- `MEAL_MANAGER`
- `DINING_MANAGER`

---

## 3. Students

Stores student profile information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Student ID |
| auth_user_id | bigint | unique, FK | Linked auth account |
| name | varchar(120) | not null | Student name |
| roll | varchar(50) | unique, not null | University roll number |
| hall_id | bigint | FK | Student hall |
| room_no | varchar(20) | nullable | Room number |
| phone | varchar(20) | nullable | Phone |

---

## 4. Wallets

Stores student balance for token purchases.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Wallet ID |
| student_id | bigint | unique, FK | Owner student |
| balance | numeric(10,2) | default 0 | Wallet balance |

---

## 5. Meal Configuration

Defines meal availability per hall per day.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Meal config ID |
| hall_id | bigint | FK, not null | Hall |
| meal_date | date | not null | Date |
| meal_type | varchar(10) | not null | Meal type |
| menu | text | nullable | Menu description |
| price | numeric(8,2) | not null | Meal price |
| purchase_deadline | timestamp | not null | Last purchase time |
| meal_start_time | timestamp | not null | Meal start |
| meal_end_time | timestamp | not null | Meal end |

**Unique Constraint:** `(hall_id, meal_date, meal_type)`

**Meal Types:** `LUNCH`, `DINNER`

---

## 6. Tokens

Represents a purchased meal token.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Token ID |
| meal_config_id | bigint | FK, not null | Meal reference |
| owner_id | bigint | FK, not null | Student owner |
| status | varchar(20) | default ACTIVE | Token state |
| created_at | timestamp | default now() | Creation time |
| used_at | timestamp | nullable | Usage time |

**Token Status:** `ACTIVE`, `USED`, `LISTED_FOR_SALE`

---

## 7. Marketplace Posts

Token resale marketplace.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Post ID |
| token_id | bigint | unique, FK, not null | Token being sold |
| seller_id | bigint | FK, not null | Seller student |
| buyer_id | bigint | FK, nullable | Buyer student |
| status | varchar(20) | default OPEN | Marketplace state |
| created_at | timestamp | default now() | Post time |

**Marketplace Status:** `OPEN`, `REQUESTED`, `COMPLETED`, `CANCELLED`

---

## 8. Transactions

Wallet and purchase history.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto-increment | Transaction ID |
| student_id | bigint | FK, not null | Student |
| type | varchar(20) | not null | Transaction type |
| amount | numeric(10,2) | not null | Amount |
| reference_id | bigint | nullable | External reference (token/topup/etc) |
| created_at | timestamp | default now() | Timestamp |

**Transaction Types:** `TOPUP`, `TOKEN_PURCHASE`

---

# Relationships

- **students.auth_user_id → auth_users.id**  
- **students.hall_id → halls.id**  
- **wallets.student_id → students.id**  
- **meal_config.hall_id → halls.id**  
- **tokens.meal_config_id → meal_config.id**  
- **tokens.owner_id → students.id**  
- **marketplace_posts.token_id → tokens.id**  
- **marketplace_posts.seller_id → students.id**  
- **marketplace_posts.buyer_id → students.id**  
- **transactions.student_id → students.id**  

---

# System Concepts (AI Context)

- Tokens represent meal entitlement.  
- Students buy tokens using wallet balance.  
- Tokens can be resold before use via marketplace.  
- Dining managers verify tokens at meal time.  
- Meal configuration defines menu, timing, and price.  