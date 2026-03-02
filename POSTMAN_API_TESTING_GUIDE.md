# Postman API Testing Guide — Digital Dining Token System

## Table of Contents
- [Setup](#setup)
- [Base URL](#base-url)
- [Authentication Flow](#authentication-flow)
- [API Endpoints](#api-endpoints)
  - [1. Admin APIs (Public)](#1-admin-apis-public)
  - [2. Auth APIs](#2-auth-apis)
  - [3. Marketplace APIs (JWT + X-User-Id)](#3-marketplace-apis-jwt--x-user-id)
  - [4. Test Helper APIs (JWT)](#4-test-helper-apis-jwt)
- [Complete Testing Workflow](#complete-testing-workflow)
- [Postman Environment Variables](#postman-environment-variables)
- [Common Errors](#common-errors)

---

## Setup

### Prerequisites
1. **PostgreSQL** running on `localhost:5432` with database `dsiApp`
2. **Backend server** running (Spring Boot on port `8080`)
3. **Postman** installed

### Start the Backend
```bash
cd backend
./mvnw spring-boot:run
```

---

## Base URL

```
http://localhost:8080/api/v1
```

> `server.servlet.context-path=/api/v1` is configured in `application.properties`, so ALL endpoints start with `/api/v1`.

---

## Postman Environment Variables

Create a Postman Environment called **"Dining Token Local"** with these variables:

| Variable      | Initial Value                    | Description                |
|---------------|----------------------------------|----------------------------|
| `base_url`    | `http://localhost:8080/api/v1`   | Base URL for all requests  |
| `jwt_token`   | *(leave empty)*                  | Auto-set after login       |
| `user_id`     | *(leave empty)*                  | Auto-set after login       |
| `admin_email` | `admin@ruet.ac.bd`               | Test admin email           |

### Auto-set JWT after Login (Tests tab script)

In the **Login** request, add this to the **Tests** tab (Post-response script):

```javascript
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    pm.environment.set("jwt_token", jsonData.token);
    pm.environment.set("user_id", jsonData.userId);
    console.log("JWT Token saved:", jsonData.token);
    console.log("User ID saved:", jsonData.userId);
}
```

---

## Authentication Flow

The app uses **JWT Bearer Token** authentication. Here's the flow:

```
Admin adds user → User receives OTP → User verifies OTP → User signs up (with password) → User logs in → Gets JWT token
```

**For marketplace testing**, the `X-User-Id` header is also required (this identifies which user is making the marketplace request).

### How to set headers in Postman:

**For JWT-protected endpoints**, go to the **Authorization** tab:
- Type: **Bearer Token**
- Token: `{{jwt_token}}`

**For marketplace endpoints**, additionally add a header:
- Key: `X-User-Id`
- Value: `{{user_id}}`

---

## API Endpoints

---

### 1. Admin APIs (Public)

> These endpoints are **publicly accessible** (no JWT needed). They are used to pre-create user accounts.

---

#### 1.1 Add User (Pre-create account)

| Field    | Value |
|----------|-------|
| Method   | `POST` |
| URL      | `{{base_url}}/admin/add-user` |
| Auth     | None |
| Headers  | `Content-Type: application/json` |

**Body (raw JSON):**
```json
{
    "email": "rumi@student.ruet.ac.bd",
    "hallId": 1,
    "role": "STUDENT"
}
```

**Expected Response (200):**
```json
{
    "success": true,
    "message": "User added successfully",
    "data": {
        "id": 1,
        "email": "rumi@student.ruet.ac.bd",
        "password": "$2a$10$...",
        "name": "CHANGE_THIS",
        "hall": {
            "id": 1,
            "name": "Shaheed Abdur Rab Hall"
        },
        "isVerified": false,
        "role": "STUDENT"
    }
}
```

**Notes:**
- `hallId` must match an existing hall ID. Halls are auto-seeded on first run.
- `role` values: `STUDENT`, `MEAL_MANAGER`, `DINING_MANAGER`
- User is created with placeholder password `CHANGE_THIS` — they must sign up to set real password
- Email must be unique

---

#### 1.2 Get User by Email

| Field    | Value |
|----------|-------|
| Method   | `GET` |
| URL      | `{{base_url}}/admin/user?email=rumi@student.ruet.ac.bd` |
| Auth     | None |

**Expected Response (200):**
```json
{
    "success": true,
    "message": "User found",
    "data": {
        "id": 1,
        "email": "rumi@student.ruet.ac.bd",
        "name": "Rumi Ahmed",
        "hall": { "id": 1, "name": "Shaheed Abdur Rab Hall" },
        "isVerified": true,
        "role": "STUDENT"
    }
}
```

---

#### 1.3 Get All Users

| Field    | Value |
|----------|-------|
| Method   | `GET` |
| URL      | `{{base_url}}/admin/users` |
| Auth     | None |

**Expected Response (200):**
```json
{
    "success": true,
    "message": "All users retrieved",
    "data": [
        { "id": 1, "email": "rumi@student.ruet.ac.bd", "name": "Rumi Ahmed", ... },
        { "id": 2, "email": "karim@student.ruet.ac.bd", "name": "Karim Hassan", ... }
    ]
}
```

---

#### 1.4 Delete User by Email

| Field    | Value |
|----------|-------|
| Method   | `DELETE` |
| URL      | `{{base_url}}/admin/user?email=test@student.ruet.ac.bd` |
| Auth     | None |

**Expected Response (200):**
```json
{
    "success": true,
    "message": "User deleted successfully",
    "data": null
}
```

---

### 2. Auth APIs

---

#### 2.1 Send OTP (Public)

| Field    | Value |
|----------|-------|
| Method   | `POST` |
| URL      | `{{base_url}}/auth/send-otp?email=rumi@student.ruet.ac.bd` |
| Auth     | None |

**Expected Response (200):**
```json
{
    "message": "OTP sent successfully",
    "email": "rumi@student.ruet.ac.bd",
    "success": true
}
```

**Note:** OTP is sent via email. Check server console logs for the OTP if email is not configured. OTP expires in 5 minutes.

---

#### 2.2 Verify OTP (Public)

| Field    | Value |
|----------|-------|
| Method   | `POST` |
| URL      | `{{base_url}}/auth/verify-otp?email=rumi@student.ruet.ac.bd&otp=123456` |
| Auth     | None |

**Expected Response (200):**
```json
{
    "message": "OTP verified successfully",
    "email": "rumi@student.ruet.ac.bd",
    "verified": true
}
```

---

#### 2.3 Sign Up (Public)

| Field    | Value |
|----------|-------|
| Method   | `POST` |
| URL      | `{{base_url}}/auth/signup` |
| Auth     | None |
| Headers  | `Content-Type: application/json` |

**Body (raw JSON):**
```json
{
    "email": "rumi@student.ruet.ac.bd",
    "password": "MyPassword123",
    "name": "Rumi Ahmed",
    "roll": "2103108",
    "phoneNo": "01712345678",
    "roomNo": "312"
}
```

**Expected Response (201):**
```json
{
    "message": "User registered successfully",
    "email": "rumi@student.ruet.ac.bd",
    "userId": 1
}
```

**Prerequisites:**
- Admin must have pre-created the user via `/admin/add-user`
- OTP must be verified via `/auth/verify-otp`

---

#### 2.4 Login ⭐

| Field    | Value |
|----------|-------|
| Method   | `POST` |
| URL      | `{{base_url}}/auth/login` |
| Auth     | None |
| Headers  | `Content-Type: application/json` |

**Body (raw JSON):**
```json
{
    "email": "rumi@student.ruet.ac.bd",
    "password": "MyPassword123"
}
```

**Expected Response (200):**
```json
{
    "token": "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJydW1pQHN0dWRlbnQucnVldC5hYy5iZCIsInJvbGUiOiJTVFVERU5UIiwiaWF0IjoxNzA5MzI2NDAwLCJleHAiOjE3MDk0MTI4MDB9...",
    "email": "rumi@student.ruet.ac.bd",
    "role": "STUDENT",
    "name": "Rumi Ahmed",
    "userId": 1,
    "hallId": 1,
    "roll": "2103108",
    "phoneNo": "01712345678",
    "roomNo": "312"
}
```

> ⭐ **Copy the `token` value** — you need it for all authenticated requests.
> 
> **Postman Tip:** Add the auto-set script from [Environment Variables](#postman-environment-variables) section to automatically save the token.

---

#### 2.5 Get Current User (JWT Required)

| Field    | Value |
|----------|-------|
| Method   | `GET` |
| URL      | `{{base_url}}/auth/me` |
| Auth     | Bearer Token → `{{jwt_token}}` |

**Expected Response (200):**
```json
{
    "token": null,
    "email": "rumi@student.ruet.ac.bd",
    "role": "STUDENT",
    "name": "Rumi Ahmed",
    "userId": 1,
    "hallId": 1,
    "roll": "2103108",
    "phoneNo": "01712345678",
    "roomNo": "312"
}
```

---

### 3. Marketplace APIs (JWT + X-User-Id)

> **All marketplace endpoints require:**
> 1. **Authorization header**: `Bearer <jwt_token>`
> 2. **X-User-Id header**: The user's ID (number)
>
> In Postman:
> - **Authorization tab** → Type: Bearer Token → Token: `{{jwt_token}}`
> - **Headers tab** → Add: `X-User-Id` = `{{user_id}}`

---

#### 3.1 Get My Available Tokens

| Field    | Value |
|----------|-------|
| Method   | `GET` |
| URL      | `{{base_url}}/marketplace/my-tokens` |
| Auth     | Bearer Token → `{{jwt_token}}` |
| Headers  | `X-User-Id: {{user_id}}` |

**Expected Response (200):**
```json
{
    "success": true,
    "message": "Your available tokens",
    "data": [
        {
            "id": 1,
            "mealId": 1,
            "mealType": "LUNCH",
            "mealDate": "2026-03-03",
            "menu": "Rice, Chicken Curry, Dal, Salad",
            "price": 60.0,
            "status": "AVAILABLE"
        },
        {
            "id": 2,
            "mealId": 2,
            "mealType": "DINNER",
            "mealDate": "2026-03-03",
            "menu": "Rice, Fish Curry, Vegetables",
            "price": 70.0,
            "status": "AVAILABLE"
        }
    ]
}
```

**Use case:** Shows tokens the user can sell on the marketplace.

---

#### 3.2 Create Sell Post (List a Token)

| Field    | Value |
|----------|-------|
| Method   | `POST` |
| URL      | `{{base_url}}/marketplace/sell` |
| Auth     | Bearer Token → `{{jwt_token}}` |
| Headers  | `X-User-Id: {{user_id}}`, `Content-Type: application/json` |

**Body (raw JSON):**
```json
{
    "tokenId": 1
}
```

**Expected Response (200):**
```json
{
    "success": true,
    "message": "Token listed for sale",
    "data": {
        "id": 1,
        "tokenId": 1,
        "mealType": "LUNCH",
        "mealDate": "2026-03-03",
        "mealMenu": "Rice, Chicken Curry, Dal, Salad",
        "mealPrice": 60.0,
        "sellerId": 1,
        "sellerName": "Rumi Ahmed",
        "buyerId": null,
        "buyerName": null,
        "status": "OPEN",
        "paymentType": null,
        "createdAt": "2026-03-02T15:30:00",
        "buyerRequestedAt": null
    }
}
```

**Error cases:**
- `400` — Token not found, not owned by user, already listed, or not AVAILABLE status

---

#### 3.3 Get Open Marketplace Posts (Same Hall)

| Field    | Value |
|----------|-------|
| Method   | `GET` |
| URL      | `{{base_url}}/marketplace/posts` |
| Auth     | Bearer Token → `{{jwt_token}}` |
| Headers  | `X-User-Id: {{user_id}}` |

**Expected Response (200):**
```json
{
    "success": true,
    "message": "Open marketplace posts",
    "data": [
        {
            "id": 1,
            "tokenId": 1,
            "mealType": "LUNCH",
            "mealDate": "2026-03-03",
            "mealMenu": "Rice, Chicken Curry, Dal, Salad",
            "mealPrice": 60.0,
            "sellerId": 1,
            "sellerName": "Rumi Ahmed",
            "buyerId": null,
            "buyerName": null,
            "status": "OPEN",
            "paymentType": null,
            "createdAt": "2026-03-02T15:30:00",
            "buyerRequestedAt": null
        }
    ]
}
```

**Note:** Only shows posts from the same hall as the requesting user. Does NOT show posts where the user is the seller.

---

#### 3.4 Send Buy Request

| Field    | Value |
|----------|-------|
| Method   | `POST` |
| URL      | `{{base_url}}/marketplace/buy` |
| Auth     | Bearer Token → `{{jwt_token}}` |
| Headers  | `X-User-Id: {{user_id}}`, `Content-Type: application/json` |

**Body (raw JSON) — Option A: Pay with in-app credit:**
```json
{
    "postId": 1,
    "paymentType": "TRANSACTION"
}
```

**Body (raw JSON) — Option B: Pay externally (cash/bKash):**
```json
{
    "postId": 1,
    "paymentType": "TOPUP"
}
```

**Expected Response (200):**
```json
{
    "success": true,
    "message": "Buy request sent — seller has 15 min to confirm",
    "data": {
        "id": 1,
        "tokenId": 1,
        "mealType": "LUNCH",
        "mealDate": "2026-03-03",
        "mealMenu": "Rice, Chicken Curry, Dal, Salad",
        "mealPrice": 60.0,
        "sellerId": 1,
        "sellerName": "Rumi Ahmed",
        "buyerId": 2,
        "buyerName": "Karim Hassan",
        "status": "PENDING",
        "paymentType": "TRANSACTION",
        "createdAt": "2026-03-02T15:30:00",
        "buyerRequestedAt": "2026-03-02T15:35:00"
    }
}
```

**Payment Types:**
| Value | Meaning | What happens on confirm |
|-------|---------|------------------------|
| `TRANSACTION` | In-app credit transfer | Buyer's wallet → Seller's wallet (automatic) |
| `TOPUP` | External payment (cash/bKash) | No wallet transfer — payment handled outside app |

**Error cases:**
- `400` — Post not found, not OPEN, buyer is the seller, buyer already has token for that meal
- `400` — Insufficient balance (only for `TRANSACTION` type)

---

#### 3.5 Confirm Transfer (Seller Confirms)

| Field    | Value |
|----------|-------|
| Method   | `POST` |
| URL      | `{{base_url}}/marketplace/listings/{id}/confirm` |
| Auth     | Bearer Token → `{{jwt_token}}` |
| Headers  | `X-User-Id: {{user_id}}` |

**Example:** `{{base_url}}/marketplace/listings/1/confirm`

**Expected Response (200):**
```json
{
    "success": true,
    "message": "Token transferred successfully",
    "data": {
        "id": 1,
        "tokenId": 1,
        "mealType": "LUNCH",
        "mealDate": "2026-03-03",
        "mealMenu": "Rice, Chicken Curry, Dal, Salad",
        "mealPrice": 60.0,
        "sellerId": 1,
        "sellerName": "Rumi Ahmed",
        "buyerId": 2,
        "buyerName": "Karim Hassan",
        "status": "COMPLETED",
        "paymentType": "TRANSACTION",
        "createdAt": "2026-03-02T15:30:00",
        "buyerRequestedAt": "2026-03-02T15:35:00"
    }
}
```

**What happens:**
- Token ownership transfers from seller to buyer
- If `paymentType = TRANSACTION`: buyer's wallet is debited, seller's wallet is credited (meal price amount)
- If `paymentType = TOPUP`: no wallet transaction (external payment)
- A `TokenTransaction` record is created
- Token status changes back to `AVAILABLE`

**Error cases:**
- `400` — Post not PENDING, user is not the seller
- `400` — Buyer has insufficient balance (for TRANSACTION type)

---

#### 3.6 Reject Buy Request (Seller Rejects)

| Field    | Value |
|----------|-------|
| Method   | `POST` |
| URL      | `{{base_url}}/marketplace/listings/{id}/reject` |
| Auth     | Bearer Token → `{{jwt_token}}` |
| Headers  | `X-User-Id: {{user_id}}` |

**Example:** `{{base_url}}/marketplace/listings/1/reject`

**Expected Response (200):**
```json
{
    "success": true,
    "message": "Buy request rejected",
    "data": {
        "id": 1,
        "status": "OPEN",
        "buyerId": null,
        "buyerName": null,
        "paymentType": null,
        "buyerRequestedAt": null
    }
}
```

**What happens:** Post goes back to OPEN, buyer & paymentType are cleared.

---

#### 3.7 Cancel Buy Request (Buyer Cancels)

| Field    | Value |
|----------|-------|
| Method   | `POST` |
| URL      | `{{base_url}}/marketplace/purchases/{id}/cancel` |
| Auth     | Bearer Token → `{{jwt_token}}` |
| Headers  | `X-User-Id: {{user_id}}` |

**Example:** `{{base_url}}/marketplace/purchases/1/cancel`

**Expected Response (200):**
```json
{
    "success": true,
    "message": "Buy request cancelled",
    "data": {
        "id": 1,
        "status": "OPEN",
        "buyerId": null,
        "buyerName": null,
        "paymentType": null,
        "buyerRequestedAt": null
    }
}
```

**Note:** Only the buyer can cancel their own request. Post returns to OPEN status.

---

#### 3.8 Cancel Listing (Seller Removes Post)

| Field    | Value |
|----------|-------|
| Method   | `DELETE` |
| URL      | `{{base_url}}/marketplace/{id}` |
| Auth     | Bearer Token → `{{jwt_token}}` |
| Headers  | `X-User-Id: {{user_id}}` |

**Example:** `{{base_url}}/marketplace/1`

**Expected Response (200):**
```json
{
    "success": true,
    "message": "Listing cancelled",
    "data": null
}
```

**What happens:** Post is deleted, token status returns to AVAILABLE.

**Error cases:**
- `400` — Post not found, user is not the seller, post already has a pending buyer (must reject first)

---

#### 3.9 Get My Listings (Seller's Posts)

| Field    | Value |
|----------|-------|
| Method   | `GET` |
| URL      | `{{base_url}}/marketplace/my-listings` |
| Auth     | Bearer Token → `{{jwt_token}}` |
| Headers  | `X-User-Id: {{user_id}}` |

**Expected Response (200):**
```json
{
    "success": true,
    "message": "Your listings",
    "data": [
        {
            "id": 1,
            "tokenId": 1,
            "mealType": "LUNCH",
            "status": "OPEN",
            "sellerId": 1,
            "sellerName": "Rumi Ahmed",
            "buyerId": null,
            "buyerName": null
        }
    ]
}
```

**Shows:** All listings by this user with status OPEN or PENDING.

---

#### 3.10 Get My Purchases (Buyer's Requests)

| Field    | Value |
|----------|-------|
| Method   | `GET` |
| URL      | `{{base_url}}/marketplace/my-purchases` |
| Auth     | Bearer Token → `{{jwt_token}}` |
| Headers  | `X-User-Id: {{user_id}}` |

**Expected Response (200):**
```json
{
    "success": true,
    "message": "Your purchase requests",
    "data": [
        {
            "id": 1,
            "tokenId": 1,
            "mealType": "LUNCH",
            "status": "PENDING",
            "sellerId": 1,
            "sellerName": "Rumi Ahmed",
            "buyerId": 2,
            "buyerName": "Karim Hassan",
            "paymentType": "TRANSACTION"
        }
    ]
}
```

---

### 4. Test Helper APIs (JWT)

> These are utility endpoints for development/testing.

---

#### 4.1 Get All Users (Test)

| Field    | Value |
|----------|-------|
| Method   | `GET` |
| URL      | `{{base_url}}/test/users` |
| Auth     | Bearer Token → `{{jwt_token}}` |

**Expected Response (200):**
```json
{
    "success": true,
    "message": null,
    "data": [
        {
            "id": 1,
            "name": "Rumi Ahmed",
            "email": "rumi@student.ruet.ac.bd",
            "hallId": 1,
            "hallName": "Shaheed Abdur Rab Hall",
            "role": "STUDENT"
        },
        {
            "id": 2,
            "name": "Karim Hassan",
            "email": "karim@student.ruet.ac.bd",
            "hallId": 1,
            "hallName": "Shaheed Abdur Rab Hall",
            "role": "STUDENT"
        }
    ]
}
```

---

#### 4.2 Get My Tokens (Test)

| Field    | Value |
|----------|-------|
| Method   | `GET` |
| URL      | `{{base_url}}/test/tokens` |
| Auth     | Bearer Token → `{{jwt_token}}` |
| Headers  | `X-User-Id: {{user_id}}` |

**Expected Response (200):**
```json
{
    "success": true,
    "message": null,
    "data": [
        {
            "id": 1,
            "mealId": 1,
            "mealType": "LUNCH",
            "mealDate": "2026-03-03",
            "menu": "Rice, Chicken Curry, Dal, Salad",
            "price": 60.0,
            "status": "AVAILABLE"
        }
    ]
}
```

---

## Complete Testing Workflow

Here is a **step-by-step testing flow** using the seeded demo data (users are auto-created on first run):

### Scenario: Full Marketplace Token Trade

Since the DataSeeder creates users with placeholder bcrypt passwords, you'll need to use real users created through the admin+signup flow, OR temporarily test with the DataSeeder users by adding a known password. For the **simplest testing path**, follow this:

---

### Quick Start (Using Admin + Auth flow):

#### Step 1: Check seeded users
```
GET {{base_url}}/admin/users
```
Note the user IDs and hall IDs.

#### Step 2: Create a test user via Admin
```
POST {{base_url}}/admin/add-user
Body: { "email": "testuser1@student.ruet.ac.bd", "hallId": 1, "role": "STUDENT" }
```

#### Step 3: Send OTP
```
POST {{base_url}}/auth/send-otp?email=testuser1@student.ruet.ac.bd
```
(Check server logs for OTP)

#### Step 4: Verify OTP
```
POST {{base_url}}/auth/verify-otp?email=testuser1@student.ruet.ac.bd&otp=<OTP_FROM_LOGS>
```

#### Step 5: Sign Up
```
POST {{base_url}}/auth/signup
Body: { "email": "testuser1@student.ruet.ac.bd", "password": "Test123!", "name": "Test User 1", "roll": "2103999", "phoneNo": "01700000001", "roomNo": "101" }
```

#### Step 6: Login → Get JWT
```
POST {{base_url}}/auth/login
Body: { "email": "testuser1@student.ruet.ac.bd", "password": "Test123!" }
```
→ **Save the `token` and `userId` from response.**

#### Step 7: View available tokens
```
GET {{base_url}}/marketplace/my-tokens
Headers: Authorization: Bearer <token>, X-User-Id: <userId>
```

#### Step 8: Sell a token
```
POST {{base_url}}/marketplace/sell
Headers: Authorization: Bearer <token>, X-User-Id: <userId>
Body: { "tokenId": <token_id_from_step_7> }
```

#### Step 9: Login as a SECOND user (repeat steps 2-6 for another user)
→ Save second user's JWT and userId.

#### Step 10: View marketplace (as second user)
```
GET {{base_url}}/marketplace/posts
Headers: Authorization: Bearer <token2>, X-User-Id: <userId2>
```

#### Step 11: Buy request (as second user)
```
POST {{base_url}}/marketplace/buy
Headers: Authorization: Bearer <token2>, X-User-Id: <userId2>
Body: { "postId": <post_id_from_step_10>, "paymentType": "TRANSACTION" }
```

#### Step 12: Confirm transfer (as first user / seller)
```
POST {{base_url}}/marketplace/listings/<post_id>/confirm
Headers: Authorization: Bearer <token1>, X-User-Id: <userId1>
```

#### Step 13: Verify token transferred
```
GET {{base_url}}/marketplace/my-tokens
Headers: Authorization: Bearer <token2>, X-User-Id: <userId2>
```
→ The bought token should now appear in the second user's tokens.

---

### Alternative Scenario: Reject + Cancel

| Step | Action | Who | Endpoint |
|------|--------|-----|----------|
| 1 | Sell token | User A | `POST /marketplace/sell` |
| 2 | Buy request | User B | `POST /marketplace/buy` |
| 3a | Reject | User A | `POST /marketplace/listings/{id}/reject` |
| -OR- | | | |
| 3b | Cancel request | User B | `POST /marketplace/purchases/{id}/cancel` |
| 4 | Check post is OPEN again | Anyone | `GET /marketplace/posts` |

### Alternative Scenario: Cancel Listing

| Step | Action | Who | Endpoint |
|------|--------|-----|----------|
| 1 | Sell token | User A | `POST /marketplace/sell` |
| 2 | Cancel listing | User A | `DELETE /marketplace/{id}` |
| 3 | Token is AVAILABLE again | User A | `GET /marketplace/my-tokens` |

---

## Quick Reference: All Endpoints

| # | Method | URL | Auth | Body |
|---|--------|-----|------|------|
| 1 | POST | `/api/v1/admin/add-user` | None | `{ email, hallId, role }` |
| 2 | GET | `/api/v1/admin/users` | None | — |
| 3 | GET | `/api/v1/admin/user?email=` | None | — |
| 4 | DELETE | `/api/v1/admin/user?email=` | None | — |
| 5 | POST | `/api/v1/auth/send-otp?email=` | None | — |
| 6 | POST | `/api/v1/auth/verify-otp?email=&otp=` | None | — |
| 7 | POST | `/api/v1/auth/signup` | None | `{ email, password, name, roll, phoneNo, roomNo }` |
| 8 | POST | `/api/v1/auth/login` | None | `{ email, password }` |
| 9 | GET | `/api/v1/auth/me` | JWT | — |
| 10 | GET | `/api/v1/marketplace/posts` | JWT + X-User-Id | — |
| 11 | GET | `/api/v1/marketplace/my-tokens` | JWT + X-User-Id | — |
| 12 | POST | `/api/v1/marketplace/sell` | JWT + X-User-Id | `{ tokenId }` |
| 13 | POST | `/api/v1/marketplace/buy` | JWT + X-User-Id | `{ postId, paymentType }` |
| 14 | POST | `/api/v1/marketplace/listings/{id}/confirm` | JWT + X-User-Id | — |
| 15 | POST | `/api/v1/marketplace/listings/{id}/reject` | JWT + X-User-Id | — |
| 16 | POST | `/api/v1/marketplace/purchases/{id}/cancel` | JWT + X-User-Id | — |
| 17 | DELETE | `/api/v1/marketplace/{id}` | JWT + X-User-Id | — |
| 18 | GET | `/api/v1/marketplace/my-listings` | JWT + X-User-Id | — |
| 19 | GET | `/api/v1/marketplace/my-purchases` | JWT + X-User-Id | — |
| 20 | GET | `/api/v1/test/users` | JWT | — |
| 21 | GET | `/api/v1/test/tokens` | JWT + X-User-Id | — |

---

## Common Errors

| Error | Status | Cause | Fix |
|-------|--------|-------|-----|
| `401 Unauthorized` | 401 | Missing/invalid JWT token | Login first, check `Authorization: Bearer <token>` header |
| `403 Forbidden` | 403 | Valid JWT but wrong role/permission | Use correct user account |
| `User not found` | 400/404 | User ID doesn't exist | Check `X-User-Id` header value |
| `Token not found` | 400 | Token ID doesn't exist | Use `GET /marketplace/my-tokens` to find valid token IDs |
| `Post not found` | 400 | Marketplace post ID doesn't exist | Use `GET /marketplace/posts` to find valid post IDs |
| `Post is not OPEN` | 400 | Trying to buy an already PENDING/COMPLETED post | Refresh posts list |
| `Cannot buy your own token` | 400 | Buyer and seller are the same user | Use a different user account |
| `Already has token for this meal` | 400 | Buyer already owns a token for that meal | Check buyer's tokens |
| `Insufficient balance` | 400 | Wallet doesn't have enough for TRANSACTION payment | Top up wallet or use TOPUP payment type |
| `Not the seller` | 400 | Trying to confirm/reject but user isn't the seller | Use seller's credentials |
| `Not the buyer` | 400 | Trying to cancel but user isn't the buyer | Use buyer's credentials |
| `Connection refused` | — | Server not running | Start with `./mvnw spring-boot:run` |

---

## Postman Collection Import (Optional)

You can create a Postman Collection by:
1. Open Postman → **New** → **Collection** → Name: "Dining Token API"
2. Add folders: `Admin`, `Auth`, `Marketplace`, `Test`
3. Add each request from the tables above
4. Set the collection-level **Authorization** to Bearer Token → `{{jwt_token}}`
5. Set collection-level **Header**: `X-User-Id` → `{{user_id}}` (for marketplace folder)

### Postman Pre-request Script (Collection Level)

Add this to the collection's **Pre-request Script** to auto-add the X-User-Id header:

```javascript
// Only add X-User-Id if variable is set
if (pm.environment.get("user_id")) {
    pm.request.headers.add({
        key: "X-User-Id",
        value: pm.environment.get("user_id")
    });
}
```
