# Implementation Summary — Meal Manager Backend API

## Overview

Complete backend implementation for the **Meal Manager** role in the University Student Hall Dining-Token Management System. All endpoints are aligned with the frontend's `MealManagerService` (see `docs/dummy_api.md`).

**Tech Stack:** Spring Boot 4.0.3, Java 21, PostgreSQL, Spring Security (JWT), Lombok

---

## API Endpoints

All endpoints require **MEAL_MANAGER** role via JWT authentication.  
Base URL: `http://localhost:8080/api/v1`

### Wallet / Top-up

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/wallet/topup` | Top up a student's wallet by roll number |
| `GET` | `/wallet/student/{studentId}` | Get a student's current wallet balance |
| `GET` | `/wallet/history?date=YYYY-MM-DD` | Get all top-up transactions for a date |

### Meal Configuration

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/meals/config` | Create a new meal config for tomorrow |
| `PUT` | `/meals/config/{id}` | Update an existing meal config |
| `GET` | `/meals/config/tomorrow` | Get tomorrow's meal configs |
| `GET` | `/meals/config/{date}` | Get meal configs for a specific date |

### Meal Availability (Close Dining + Refund)

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/meals/availability/{date}` | Check lunch/dinner availability |
| `PUT` | `/meals/availability/{date}` | Close dining (auto-refunds all active tokens) |

### Reports

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/reports/sales?date=YYYY-MM-DD` | Token sales counts (lunch/dinner) |
| `GET` | `/reports/revenue?date=YYYY-MM-DD` | Revenue breakdown (lunch/dinner) |
| `GET` | `/reports/wallet-topups?date=YYYY-MM-DD` | Wallet top-up transactions for a date |

### Dashboard

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/dashboard` | Aggregated today's data (counts, revenue, availability) |

### History

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/history/meals` | Daily meal history (last 30 days) |
| `GET` | `/history/credits` | Daily credit/top-up history (last 30 days) |

---

## Files Changed / Created

### Models (Fixed)

| File | Change |
|------|--------|
| `models/Wallet.java` | Fixed `@MapsId` bug → uses `@GeneratedValue` + `@JoinColumn(name="user_id")` |

### DTOs (New)

| File | Purpose |
|------|---------|
| `dto/mealmanager/StudentBalanceResponse.java` | Student balance lookup response |
| `dto/mealmanager/CreditTransactionResponse.java` | Single top-up transaction in wallet history |
| `dto/mealmanager/MealConfigResponse.java` | Meal config details (create/get) |
| `dto/mealmanager/MealAvailabilityRequest.java` | Request to update meal availability |
| `dto/mealmanager/MealAvailabilityResponse.java` | Meal open/closed status |
| `dto/mealmanager/SalesReportResponse.java` | Lunch/dinner token sale counts |
| `dto/mealmanager/RevenueReportResponse.java` | Lunch/dinner revenue figures |
| `dto/mealmanager/DashboardResponse.java` | Aggregated dashboard data |
| `dto/mealmanager/DailyMealHistoryResponse.java` | Daily meal history entry |
| `dto/mealmanager/DailyCreditHistoryResponse.java` | Daily credit history grouped by date |

### DTOs (Updated)

| File | Change |
|------|--------|
| `dto/mealmanager/TopUpRequest.java` | `studentId` changed from `Long` → `String` (roll number) |

### Repositories (Updated)

| File | Change |
|------|--------|
| `repositories/MealRepository.java` | Added `findByHallIdAndMealDateBetweenOrderByMealDateDesc()` for history |
| `repositories/CoinTransactionRepository.java` | Added `findTopUpsBySenderAndDateRange()`, `countTopUpsBySenderAndDay()` |
| `repositories/UserRepository.java` | Added `countByHallIdAndRole()` for dashboard student count |

### Service (Rewritten)

| File | Change |
|------|--------|
| `services/MealManagerService.java` | Complete rewrite with 15 public methods + helpers |

**Service Methods:**
1. `topUpWallet()` — wallet top-up via roll number
2. `getStudentBalance()` — balance lookup
3. `getWalletHistory()` — date-filtered top-up history
4. `createMealConfig()` — create meal for tomorrow
5. `updateMealConfig()` — update existing meal
6. `getTomorrowConfig()` — get tomorrow's configs
7. `getMealConfigByDate()` — get configs by date
8. `getMealAvailability()` — check open/closed status
9. `updateMealAvailability()` — close dining with refund
10. `getSalesReport()` — token sales counts
11. `getRevenueReport()` — revenue calculations
12. `getWalletTopups()` — top-up report for a date
13. `getDashboardData()` — aggregated today's data
14. `getMealHistory()` — last 30 days meal history
15. `getCreditHistory()` — last 30 days credit history

### Controller (Rewritten)

| File | Change |
|------|--------|
| `controllers/MealManagerController.java` | Rewritten with 15 endpoints under `/api/v1` |

### Config (Updated)

| File | Change |
|------|--------|
| `config/SecurityConfig.java` | Changed `/meal-manager/**` → `/api/v1/**` for MEAL_MANAGER role |

---

## Close Dining / Refund Flow

When `PUT /api/v1/meals/availability/{date}` is called with `isLunchAvailable: false`:

1. Find the LUNCH meal config for that date in the manager's hall
2. If not already closed:
   - Find all tokens for that meal
   - For each ACTIVE token (not USED):
     - Refund the meal price to the student's wallet
     - Record a `REFUND` type CoinTransaction (manager → student)
     - Delete the token
   - Mark the meal as `isClosed = true`
3. Return updated availability status

---

## Request/Response Examples

### Top-up Wallet
```
POST /api/v1/wallet/topup
{
  "studentId": "S2021001",
  "amount": 500.00
}

Response:
{
  "message": "Wallet topped up successfully",
  "data": {
    "studentId": 5,
    "studentName": "Rahim Uddin",
    "balance": 750.00
  },
  "success": true
}
```

### Create Meal Config
```
POST /api/v1/meals/config
{
  "mealType": "LUNCH",
  "menu": "Rice, Dal, Fish Curry, Salad",
  "price": 55.0,
  "purchaseStartTime": "2026-03-02T08:00:00",
  "purchaseEndTime": "2026-03-02T22:00:00"
}
```

### Close Dining
```
PUT /api/v1/meals/availability/2026-03-02
{
  "date": "2026-03-02",
  "isLunchAvailable": false,
  "isDinnerAvailable": true
}
```

### Dashboard
```
GET /api/v1/dashboard

Response:
{
  "message": "Dashboard data",
  "data": {
    "lunchCount": 142,
    "dinnerCount": 98,
    "lunchRevenue": 7810.0,
    "dinnerRevenue": 6370.0,
    "totalStudents": 380,
    "todayTopUps": 12,
    "isLunchAvailable": true,
    "isDinnerAvailable": true,
    "totalMeals": 240,
    "totalRevenue": 14180.0
  },
  "success": true
}
```

---

## Database Notes

- **Wallet table**: The `@MapsId` bug was fixed. `wallets` table now has its own auto-generated `id` column and a separate `user_id` foreign key column. **You may need to drop and recreate the `wallets` table** if it was already created with the old schema:
  ```sql
  DROP TABLE IF EXISTS wallets CASCADE;
  ```
  Spring Boot `ddl-auto=update` will recreate it automatically on next startup.

- **CoinTransaction types**: Now includes `TOPUP`, `TRANSACTION`, and `REFUND` types.

---

## Team Notes

- Frontend should use `String` roll numbers for `studentId` in all wallet-related APIs
- All responses are wrapped in `ApiResponse<T>` with `message`, `data`, and `success` fields
- JWT token must be included in `Authorization: Bearer <token>` header
- Date parameters use `YYYY-MM-DD` format
