# Digital Dining Token Management System - Authentication API

## Overview
This is the authentication module for the Digital Dining Token Management System backend built with Spring Boot and Spring Security using JWT tokens.

## Key Features
- ✅ User signup with email and password
- ✅ JWT-based authentication
- ✅ Role-based access control (STUDENT, MEAL_MANAGER, DINING_MANAGER)
- ✅ Student profile creation with wallet initialization
- ✅ BCrypt password hashing for security
- ✅ Automatic hall assignment for students
- ✅ Transaction support with database consistency

## Database Tables Created
- `auth_users` - User authentication data
- `students` - Student profile information
- `wallets` - Student digital wallets (linked to students)
- `halls` - University halls (dummy data initialized)

## API Endpoints

### 1. Signup
**Endpoint:** `POST /api/auth/signup`  
**Access:** Public (No authentication required)  

**Request Body:**
```json
{
  "email": "student@example.com",
  "password": "SecurePassword123",
  "name": "John Doe",
  "roll": "20230001",
  "role": "STUDENT",
  "hallId": 1,
  "roomNo": "205",
  "phone": "+8801712345678"
}
```

**Response (201 Created):**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "email": "student@example.com",
  "role": "STUDENT",
  "name": "John Doe",
  "userId": 1
}
```

**Error Responses:**
- `409 Conflict` - Email already registered
- `404 Not Found` - Hall not found

### 2. Login
**Endpoint:** `POST /api/auth/login`  
**Access:** Public (No authentication required)  

**Request Body:**
```json
{
  "email": "student@example.com",
  "password": "SecurePassword123"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "email": "student@example.com",
  "role": "STUDENT",
  "name": "John Doe",
  "userId": 1
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid email or password
- `404 Not Found` - User not found

### 3. Get Current User
**Endpoint:** `GET /api/auth/me`  
**Access:** Requires valid JWT token  
**Header:** `Authorization: Bearer {token}`

**Response (200 OK):**
```json
{
  "token": null,
  "email": "student@example.com",
  "role": null,
  "name": null,
  "userId": 0
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid or missing token

## Authentication Flow

### Token Structure
JWT tokens contain:
- **Subject (sub):** User email
- **Role (role):** User role (STUDENT, MEAL_MANAGER, DINING_MANAGER)
- **Issued At (iat):** Token creation timestamp
- **Expiration (exp):** Token expiry (default: 24 hours)

### Request with Token
```bash
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzUxMiJ9..."
```

## Security Configuration

### Password Encoding
- **Algorithm:** BCrypt with salt rounds = 10
- Passwords are never stored in plain text
- Password validation during login is automatic

### JWT Configuration
- **Secret Key:** Configured in `application.properties` (jwt.secret)
- **Algorithm:** HS512 (HMAC with SHA-512)
- **Expiration:** 24 hours (86400000ms) - Configurable via `jwt.expiration`
- **Validation:** Token signature and expiry are verified on each request

### Session Management
- **Session Policy:** STATELESS (No server-side sessions)
- **CSRF Protection:** Disabled for stateless JWT authentication
- **CORS:** Enabled for all origins (*)

## Roles and Permissions

### STUDENT
- Can signup with hall assignment
- Gets automatic wallet initialization with 0 balance
- Can authenticate and access protected endpoints

### MEAL_MANAGER
- Can signup without student profile
- No automatic wallet creation
- Can access manager endpoints (future implementation)

### DINING_MANAGER
- Can signup without student profile
- No automatic wallet creation
- Can access dining manager endpoints (future implementation)

## Running the Application

### Prerequisites
- Java 21+
- PostgreSQL 12+
- Maven 3.8+

### Setup
1. Ensure PostgreSQL is running
2. Create database:
   ```sql
   CREATE DATABASE "dsiApp";
   ```
3. Update `application.properties` with correct credentials:
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/dsiApp
   spring.datasource.username=your_username
   spring.datasource.password=your_password
   ```

### Build and Run
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

The application will start on `http://localhost:8080`

## Testing Endpoints

### Test Signup
```bash
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test@123",
    "name": "Test Student",
    "roll": "20230042",
    "role": "STUDENT",
    "hallId": 1,
    "roomNo": "101",
    "phone": "+8801700000000"
  }'
```

### Test Login
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test@123"
  }'
```

### Test Protected Endpoint
```bash
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer <your_token_here>"
```

## Error Handling

### Standard Error Response
```json
{
  "message": "Error description",
  "status": 400,
  "timestamp": 1645264800000
}
```

### Common Error Scenarios
| Error | Status | Reason |
|-------|--------|--------|
| Duplicate Email | 409 | Email already registered in system |
| Invalid Credentials | 401 | Wrong email/password combination |
| Hall Not Found | 404 | Specified hall ID doesn't exist |
| Unauthorized Access | 401 | Missing or invalid JWT token |
| Internal Server Error | 500 | Unexpected server error |

## Database Schema

### auth_users
```sql
CREATE TABLE auth_users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(120) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  is_verified BOOLEAN DEFAULT false,
  role VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### students
```sql
CREATE TABLE students (
  id BIGSERIAL PRIMARY KEY,
  auth_user_id BIGINT UNIQUE NOT NULL,
  name VARCHAR(120) NOT NULL,
  roll VARCHAR(50) UNIQUE NOT NULL,
  hall_id BIGINT,
  room_no VARCHAR(20),
  phone VARCHAR(20),
  FOREIGN KEY (auth_user_id) REFERENCES auth_users(id),
  FOREIGN KEY (hall_id) REFERENCES halls(id)
);
```

### wallets
```sql
CREATE TABLE wallets (
  id BIGSERIAL PRIMARY KEY,
  student_id BIGINT UNIQUE NOT NULL,
  balance NUMERIC(10,2) DEFAULT 0,
  FOREIGN KEY (student_id) REFERENCES students(id)
);
```

### halls
```sql
CREATE TABLE halls (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL
);
```

## Dummy Data

### Pre-initialized Halls
- Tanti Hall (ID: 1)
- Rajshahi Hall (ID: 2)
- Chittagong Hall (ID: 3)
- Sylhet Hall (ID: 4)
- Khulna Hall (ID: 5)

These are automatically created on first application startup.

## Next Steps

The authentication system is now ready. Future implementations will include:
- Token purchase system
- Marketplace functionality
- QR code generation and validation
- Wallet management
- Meal configuration endpoints
- Manager-specific endpoints

## Security Best Practices

1. **Change JWT Secret:** Update `jwt.secret` in `application.properties` with a strong, random secret
2. **CORS Configuration:** Update `@CrossOrigin` in controller for production (remove `*`)
3. **HTTPS:** Always use HTTPS in production
4. **Token Management:** Implement token refresh mechanism for better security
5. **Rate Limiting:** Add rate limiting to prevent brute force attacks
6. **Input Validation:** Add comprehensive validation (already partially done with DTOs)

## Support
For issues or questions, refer to the main project documentation or contact the development team.
