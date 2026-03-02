# Digital Dining Token Management System  
## Final REST API Specification

**Base URL:** `/api/v1`  
**Authentication:** JWT Bearer Token required for all endpoints except `/auth/*`  

---

# 0. Admin MODULE

## Database Control
- **POST** `/admin/add-user`

# 1. Auth Module

## Signup & Verification
- **POST** `/auth/signup/send-otp`
- **POST** `/auth/signup/verify-otp`
- **POST** `/auth/signup/complete`

## Login
- **POST** `/auth/login`

## Password Reset
- **POST** `/auth/password/send-otp`
- **POST** `/auth/password/verify-otp`
- **POST** `/auth/password/reset`

## Current User Info
- **GET** `/auth/me`

---

# 2. Student Module

- **GET** `/students/me`  
- **GET** `/students/me/tokens`  
- **GET** `/students/me/transactions`  

---

# 3. Wallet Module

## Student
- **GET** `/wallet/me`

## Meal Manager
- **POST** `/wallet/topup`
- **GET** `/wallet/student/{studentId}`
- **GET** `/wallet/history?date=YYYY-MM-DD`

---

# 4. Meal Configuration Module

## Meal Manager Actions
- **POST** `/meals/config`
- **PUT** `/meals/config/{id}`
- **GET** `/meals/config/tomorrow`
- **GET** `/meals/config/{date}`

## Student View
- **GET** `/meals/tomorrow`

---

# 5. Token Module

## Purchase Token
- **POST** `/tokens/purchase`

## Student Token Queries
- **GET** `/tokens/me`
- **GET** `/tokens/{id}`

## QR Validation Flow
- **POST** `/tokens/{id}/generate-qr`
- **POST** `/tokens/validate-qr`
- **POST** `/tokens/{id}/mark-used`

---

# 6. Marketplace Module

## Sell Posts
- **POST** `/marketplace/posts`
- **GET** `/marketplace/posts`
- **GET** `/marketplace/posts/{id}`

## Buy / Transfer Flow
- **POST** `/marketplace/posts/{id}/request`
- **POST** `/marketplace/posts/{id}/confirm`
- **POST** `/marketplace/posts/{id}/cancel`

## Student Marketplace History
- **GET** `/marketplace/me/sales`
- **GET** `/marketplace/me/purchases`

---

# 7. Dining Manager Module

## QR Scanning & Validation
- **POST** `/dining/scan`

## Dining Dashboard
- **GET** `/dining/today/stats`
- **GET** `/dining/today/remaining`
- **GET** `/dining/today/served`

---

# 8. Reporting Module

## Meal Manager Reports
- **GET** `/reports/sales?date=YYYY-MM-DD`
- **GET** `/reports/wallet-topups?date=YYYY-MM-DD`
- **POST** `/manager/menu`
- **POST** `/manager/token-price`
- **POST** `/manager/purchase-deadline`
- **GET** `/manager/sales-summary`




## Future / Admin Reports
- **GET** `/reports/hall-summary`
- **GET** `/reports/student/{id}`

---

# 9. Hall Module (Utility)

- **GET** `/halls/me`
- **GET** `/halls/{id}`
- **GET** `/halls`

---

# ✔ Coverage Summary

This API design supports:

- Authentication & role routing  
- Wallet and transaction management  
- Next-day token purchasing rules  
- Meal configuration per hall  
- Marketplace resale flow  
- Secure QR validation  
- Dining manager scanning dashboard  
- Financial and operational reporting  

The structure is consistent with:
- SRS functional requirements  
- PostgreSQL schema design  
- Spring Boot controller/service layering  

---
