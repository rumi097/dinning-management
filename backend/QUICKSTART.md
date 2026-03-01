# Quick Start Guide - Authentication System

## 🚀 Getting Started in 5 Minutes

### Prerequisites
- Java 21+ installed
- PostgreSQL 12+ running
- Maven 3.8+ installed

### Step 1: Database Setup

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE "dsiApp";

# Exit
\q
```

### Step 2: Configure Connection
Edit `backend/src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/dsiApp
spring.datasource.username=postgre
spring.datasource.password=12345678
```

### Step 3: Build & Run

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

✅ Server starts on `http://localhost:8080`

---

## 📝 Quick API Test

### Signup
```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "Student@123",
    "name": "John Doe",
    "roll": "20230001",
    "role": "STUDENT",
    "hallId": 1,
    "roomNo": "203",
    "phone": "+8801712345678"
  }'
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "email": "student@example.com",
  "role": "STUDENT",
  "name": "John Doe",
  "userId": 1
}
```

### Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "Student@123"
  }'
```

### Use Token
```bash
TOKEN="your_token_here"
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `AUTHENTICATION.md` | Complete API documentation |
| `TESTING.md` | Testing guide with examples |
| `PROJECT_STRUCTURE.md` | File structure and implementation details |

---

## 🎯 Key Features

✅ JWT-based authentication  
✅ Role-based access control (STUDENT, MEAL_MANAGER, DINING_MANAGER)  
✅ Automatic student profile creation  
✅ Automatic wallet initialization  
✅ BCrypt password hashing  
✅ Secure token validation  
✅ Exception handling with detailed errors  
✅ CORS enabled  

---

## 📊 Pre-initialized Halls

Halls are automatically created on startup:
- Tanti Hall (ID: 1)
- Rajshahi Hall (ID: 2)
- Chittagong Hall (ID: 3)
- Sylhet Hall (ID: 4)
- Khulna Hall (ID: 5)

Use these IDs when signing up as students.

---

## 🔧 Available Roles

| Role | Student Profile | Wallet | Notes |
|------|-----------------|--------|-------|
| STUDENT | Yes | Yes | Full profile creation |
| MEAL_MANAGER | No | No | Can manage meals |
| DINING_MANAGER | No | No | Can scan QR codes |

---

## 🛡️ Security Details

- **Password Encoding:** BCrypt
- **Token Algorithm:** HS512
- **Token Expiration:** 24 hours
- **Verification:** Real-time JWT validation
- **CSRF:** Disabled (stateless JWT)
- **Session:** None (stateless)

---

## 🐛 Troubleshooting

### Connection Refused
```
Error: Connection to localhost:5432 refused
Solution: Ensure PostgreSQL is running
```

### Port Already in Use
```
Error: Address already in use: 8080
Solution: Kill process on 8080 or change port
```

### Database Not Found
```
Error: ERROR: database "dsiApp" does not exist
Solution: Run CREATE DATABASE "dsiApp"; in PostgreSQL
```

### Invalid Credentials Error
```
Error: Invalid email or password
Solution: Check email/password spelling, ensure user exists
```

---

## 📖 What's Next?

The authentication system is complete. You can now:

1. ✅ Implement token purchase system
2. ✅ Add wallet management endpoints
3. ✅ Create marketplace functionality
4. ✅ Add QR code generation
5. ✅ Build meal management features
6. ✅ Add manager-specific endpoints

---

## 🔗 API Endpoints Summary

```
PUBLIC ENDPOINTS
POST   /api/auth/signup    - Register new user
POST   /api/auth/login     - Login and get token

PROTECTED ENDPOINTS
GET    /api/auth/me        - Get current user info
```

---

## 💾 Database Schema

4 tables created:
- `halls` - University halls
- `auth_users` - Authentication data
- `students` - Student profiles
- `wallets` - Digital wallets

All relationships configured with foreign keys.

---

## ✨ Code Quality

- Clean architecture with separation of concerns
- Spring Security best practices
- Exception handling with custom exceptions
- DTO pattern for data transfer
- Transactional operations for data consistency
- Repository pattern for data access

---

## 📞 Support

For detailed information:
- Read `AUTHENTICATION.md` for API details
- Read `TESTING.md` for test examples
- Read `PROJECT_STRUCTURE.md` for implementation details

---

**Status:** ✅ Authentication System Ready to Use!
