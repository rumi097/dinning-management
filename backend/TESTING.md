# Authentication API Testing Guide

## Postman Testing

### Setup
1. Import the collection or create new requests in Postman
2. Create a Postman environment with variable:
   - `base_url`: `http://localhost:8080`
   - `token`: Leave empty initially

### Test Scenarios

#### 1. Signup as Student
**Method:** POST  
**URL:** `{{base_url}}/api/auth/signup`  
**Headers:** Content-Type: application/json

**Body:**
```json
{
  "email": "student1@example.com",
  "password": "SecurePass@123",
  "name": "Ahmed Rahman",
  "roll": "20230101",
  "role": "STUDENT",
  "hallId": 1,
  "roomNo": "203",
  "phone": "+8801712345678"
}
```

**Status:** 201 Created

**Save Response:**
- Copy the `token` value
- Set Postman variable: `{{token}}` = token value

---

#### 2. Signup as Meal Manager
**Method:** POST  
**URL:** `{{base_url}}/api/auth/signup`  
**Headers:** Content-Type: application/json

**Body:**
```json
{
  "email": "manager@example.com",
  "password": "ManagerPass@123",
  "name": "Manager",
  "roll": "MGR001",
  "role": "MEAL_MANAGER",
  "hallId": null
}
```

**Status:** 201 Created

---

#### 3. Signup as Dining Manager
**Method:** POST  
**URL:** `{{base_url}}/api/auth/signup`  
**Headers:** Content-Type: application/json

**Body:**
```json
{
  "email": "dining@example.com",
  "password": "DiningPass@123",
  "name": "Dining Manager",
  "roll": "DIN001",
  "role": "DINING_MANAGER",
  "hallId": null
}
```

**Status:** 201 Created

---

#### 4. Login with Valid Credentials
**Method:** POST  
**URL:** `{{base_url}}/api/auth/login`  
**Headers:** Content-Type: application/json

**Body:**
```json
{
  "email": "student1@example.com",
  "password": "SecurePass@123"
}
```

**Status:** 200 OK

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "email": "student1@example.com",
  "role": "STUDENT",
  "name": "Ahmed Rahman",
  "userId": 1
}
```

---

#### 5. Login with Wrong Password
**Method:** POST  
**URL:** `{{base_url}}/api/auth/login`  
**Headers:** Content-Type: application/json

**Body:**
```json
{
  "email": "student1@example.com",
  "password": "WrongPassword"
}
```

**Expected Status:** 401 Unauthorized  
**Expected Response:**
```json
{
  "message": "Invalid email or password",
  "status": 401,
  "timestamp": 1645264800000
}
```

---

#### 6. Login with Non-existent Email
**Method:** POST  
**URL:** `{{base_url}}/api/auth/login`  
**Headers:** Content-Type: application/json

**Body:**
```json
{
  "email": "nonexistent@example.com",
  "password": "AnyPassword"
}
```

**Expected Status:** 401 Unauthorized

---

#### 7. Signup Duplicate Email
**Method:** POST  
**URL:** `{{base_url}}/api/auth/signup`  
**Headers:** Content-Type: application/json

**Body:**
```json
{
  "email": "student1@example.com",
  "password": "DifferentPass@123",
  "name": "Different Name",
  "roll": "20230999",
  "role": "STUDENT",
  "hallId": 1
}
```

**Expected Status:** 409 Conflict  
**Expected Response:**
```json
{
  "message": "Email already registered: student1@example.com",
  "status": 409,
  "timestamp": 1645264800000
}
```

---

#### 8. Get Current User (Authenticated)
**Method:** GET  
**URL:** `{{base_url}}/api/auth/me`  
**Headers:** 
- Authorization: `Bearer {{token}}`

**Status:** 200 OK

**Response:**
```json
{
  "token": null,
  "email": "student1@example.com",
  "role": null,
  "name": null,
  "userId": 0
}
```

---

#### 9. Get Current User (No Token)
**Method:** GET  
**URL:** `{{base_url}}/api/auth/me`  
**Headers:** (None)

**Expected Status:** 401 Unauthorized  
**Expected Response:**
```json
"Not authenticated"
```

---

#### 10. Get Current User (Invalid Token)
**Method:** GET  
**URL:** `{{base_url}}/api/auth/me`  
**Headers:** 
- Authorization: `Bearer invalid.token.here`

**Expected Status:** 401 Unauthorized

---

## cURL Testing

### Signup
```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "John@123",
    "name": "John Doe",
    "roll": "20230201",
    "role": "STUDENT",
    "hallId": 2,
    "roomNo": "305",
    "phone": "+8801700000001"
  }'
```

### Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "John@123"
  }'
```

### Get Current User
```bash
TOKEN="your_jwt_token_here"
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

---

## Test Data Summary

### Available Halls
```
1. Tanti Hall
2. Rajshahi Hall
3. Chittagong Hall
4. Sylhet Hall
5. Khulna Hall
```

### Test Users (After Running Tests)
| Email | Password | Role | Hall |
|-------|----------|------|------|
| student1@example.com | SecurePass@123 | STUDENT | Tanti Hall |
| manager@example.com | ManagerPass@123 | MEAL_MANAGER | - |
| dining@example.com | DiningPass@123 | DINING_MANAGER | - |

---

## Database Verification

### Check Users Created
```sql
SELECT id, email, role, is_verified, created_at FROM auth_users;
```

### Check Students Created
```sql
SELECT s.id, s.name, s.roll, h.name as hall_name 
FROM students s 
LEFT JOIN halls h ON s.hall_id = h.id;
```

### Check Wallets Created
```sql
SELECT w.id, w.student_id, w.balance 
FROM wallets w;
```

---

## Common Issues and Solutions

### Issue: 404 Hall Not Found
**Cause:** Invalid hallId in signup request  
**Solution:** Use valid hall IDs (1-5) or check SQL query above

### Issue: 409 Email Already Registered
**Cause:** Email already exists in database  
**Solution:** Use a different email address or delete the user from database

### Issue: 401 Invalid Token
**Cause:** Token expired or malformed  
**Solution:** Login again to get a new token

### Issue: Connection Refused
**Cause:** Application not running or wrong port  
**Solution:** Ensure application started with `mvn spring-boot:run`

### Issue: Database Connection Failed
**Cause:** PostgreSQL not running or wrong credentials  
**Solution:** Check PostgreSQL service and application.properties configuration

---

## Performance Testing

### Load Test with Apache Bench
```bash
# 100 requests, 10 concurrent
ab -n 100 -c 10 \
  -p signup.json \
  -T application/json \
  http://localhost:8080/api/auth/signup
```

### Rate Limiting Test
Make multiple rapid requests to test server stability (future enhancement needed)

---

## Security Testing

### SQL Injection Test
Try email: `admin' OR '1'='1`
Expected: Registration with literal email value (safe)

### Password Strength Test
Try weak password: `123`
Expected: Accepted (validation can be added)

### Token Manipulation Test
Modify token and send in Authorization header
Expected: 401 Unauthorized or failed validation
