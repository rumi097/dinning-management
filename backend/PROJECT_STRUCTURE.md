# Authentication System Implementation - Complete File Structure

## Project Overview
A complete JWT-based authentication system for the Digital Dining Token Management System using Spring Boot 4.0.3 with Spring Security.

## Directory Structure

```
backend/
├── src/
│   ├── main/
│   │   ├── java/dsi/ruet/backend/
│   │   │   ├── BackendApplication.java
│   │   │   ├── models/
│   │   │   │   ├── Hall.java
│   │   │   │   ├── AuthUser.java
│   │   │   │   ├── Student.java
│   │   │   │   └── Wallet.java
│   │   │   ├── controllers/
│   │   │   │   └── AuthenticationController.java
│   │   │   ├── services/
│   │   │   │   └── AuthenticationService.java
│   │   │   ├── repositories/
│   │   │   │   ├── AuthUserRepository.java
│   │   │   │   ├── StudentRepository.java
│   │   │   │   ├── WalletRepository.java
│   │   │   │   └── HallRepository.java
│   │   │   ├── dto/
│   │   │   │   ├── SignupRequest.java
│   │   │   │   ├── LoginRequest.java
│   │   │   │   ├── AuthResponse.java
│   │   │   │   ├── ErrorResponse.java
│   │   │   │   ├── UserDto.java
│   │   │   │   └── StudentDto.java
│   │   │   ├── security/
│   │   │   │   ├── JwtTokenProvider.java
│   │   │   │   ├── JwtAuthenticationFilter.java
│   │   │   │   └── CustomUserDetailsService.java
│   │   │   ├── config/
│   │   │   │   ├── SecurityConfig.java
│   │   │   │   └── DataInitializer.java
│   │   │   └── exception/
│   │   │       ├── GlobalExceptionHandler.java
│   │   │       ├── ResourceNotFoundException.java
│   │   │       ├── AuthenticationException.java
│   │   │       └── DuplicateEmailException.java
│   │   └── resources/
│   │       └── application.properties
│   └── test/
└── pom.xml
```

## Files Created and Their Purpose

### Models (Entity Classes)
1. **Hall.java**
   - Represents university halls
   - Fields: id, name
   - Used for hall-based dining system

2. **AuthUser.java**
   - Core authentication entity implementing UserDetails
   - Fields: id, email, passwordHash, isVerified, role, createdAt
   - Implements Spring Security UserDetails interface

3. **Student.java**
   - Student profile connected to AuthUser
   - Fields: id, authUser, name, roll, hall, roomNo, phone
   - One-to-one relationship with AuthUser

4. **Wallet.java**
   - Digital wallet for students
   - Fields: id, student, balance
   - One-to-one relationship with Student

---

### Controllers
5. **AuthenticationController.java**
   - REST endpoints for signup, login, and user info
   - Handles HTTP requests and responses
   - Public endpoints: /api/auth/signup, /api/auth/login
   - Protected endpoint: /api/auth/me

---

### Services
6. **AuthenticationService.java**
   - Core business logic for authentication
   - Methods: signup(), login(), getCurrentUser()
   - Handles user creation, student profile creation, wallet initialization
   - Password encoding and JWT generation

---

### Repositories
7. **AuthUserRepository.java**
   - Database access for AuthUser
   - Methods: findByEmail(), existsByEmail()

8. **StudentRepository.java**
   - Database access for Student
   - Methods: findByAuthUserId(), findByRoll()

9. **WalletRepository.java**
   - Database access for Wallet
   - Methods: findByStudentId()

10. **HallRepository.java**
    - Database access for Hall
    - Methods: findByName()

---

### DTOs (Data Transfer Objects)
11. **SignupRequest.java**
    - Request DTO for user signup
    - Fields: email, password, name, roll, role, hallId, roomNo, phone

12. **LoginRequest.java**
    - Request DTO for user login
    - Fields: email, password

13. **AuthResponse.java**
    - Response DTO for authentication endpoints
    - Fields: token, email, role, name, userId

14. **ErrorResponse.java**
    - Standard error response format
    - Fields: message, status, timestamp

15. **UserDto.java**
    - Data transfer object for user information
    - Fields: id, email, role, isVerified, createdAt

16. **StudentDto.java**
    - Data transfer object for student information
    - Fields: id, name, roll, hallName, roomNo, phone

---

### Security Components
17. **JwtTokenProvider.java**
    - JWT token generation and validation
    - Methods: generateToken(), generateTokenFromEmail(), validateToken()
    - Methods: getEmailFromToken(), getRoleFromToken()
    - Uses HS512 signing algorithm

18. **JwtAuthenticationFilter.java**
    - Extracts and verifies JWT tokens from requests
    - Implements OncePerRequestFilter
    - Sets authentication in SecurityContext

19. **CustomUserDetailsService.java**
    - Implements UserDetailsService for Spring Security
    - Loads user details by email from database

---

### Configuration
20. **SecurityConfig.java**
    - Spring Security configuration
    - Configures JWT filter chain
    - Defines password encoder (BCrypt)
    - Sets up authorization rules and CORS

21. **DataInitializer.java**
    - Initializes dummy hall data on application startup
    - Creates 5 halls for testing

---

### Exception Handling
22. **GlobalExceptionHandler.java**
    - Centralized exception handling
    - Handles all custom and standard exceptions
    - Returns consistent error responses

23. **ResourceNotFoundException.java**
    - Custom exception for resource not found scenarios

24. **AuthenticationException.java**
    - Custom exception for authentication failures

25. **DuplicateEmailException.java**
    - Custom exception for duplicate email registration

---

### Configuration Files
26. **application.properties**
    - Database configuration
    - JWT secret and expiration settings
    - Hibernate/JPA configuration

27. **pom.xml**
    - Maven dependencies including:
      - Spring Boot Starters
      - Spring Security
      - JWT (JJWT)
      - PostgreSQL Driver
      - Lombok
      - JPA/Hibernate

---

### Documentation
28. **AUTHENTICATION.md**
    - Complete API documentation
    - Endpoint descriptions with examples
    - Error handling guide
    - Database schema
    - Running instructions

29. **TESTING.md**
    - Testing guide with Postman examples
    - cURL command examples
    - Test data reference
    - Database verification queries
    - Troubleshooting guide

30. **PROJECT_STRUCTURE.md** (This file)
    - File directory structure
    - File purposes and descriptions

---

## Dependencies Added to pom.xml

```xml
<!-- Spring Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- JWT Token Support (JJWT) -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
```

---

## API Endpoints Summary

### Public Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | /api/auth/signup | User registration |
| POST | /api/auth/login | User authentication |

### Protected Endpoints
| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | /api/auth/me | Get current authenticated user |

---

## Database Tables

### 1. halls
```sql
id (BIGINT, PK)
name (VARCHAR(100), UNIQUE)
```

### 2. auth_users
```sql
id (BIGINT, PK)
email (VARCHAR(120), UNIQUE)
password_hash (VARCHAR(255))
is_verified (BOOLEAN, DEFAULT: false)
role (VARCHAR(20))
created_at (TIMESTAMP)
```

### 3. students
```sql
id (BIGINT, PK)
auth_user_id (BIGINT, UNIQUE, FK -> auth_users)
name (VARCHAR(120))
roll (VARCHAR(50), UNIQUE)
hall_id (BIGINT, FK -> halls)
room_no (VARCHAR(20))
phone (VARCHAR(20))
```

### 4. wallets
```sql
id (BIGINT, PK)
student_id (BIGINT, UNIQUE, FK -> students)
balance (NUMERIC(10,2), DEFAULT: 0)
```

---

## Pre-initialized Dummy Data

### Halls
1. Tanti Hall
2. Rajshahi Hall
3. Chittagong Hall
4. Sylhet Hall
5. Khulna Hall

---

## Security Features Implemented

✅ **Password Security**
- BCrypt hashing with salt
- Never stored in plain text

✅ **JWT Authentication**
- HS512 signing algorithm
- 24-hour token expiration
- Token validation on each request

✅ **Role-Based Access Control**
- Three roles: STUDENT, MEAL_MANAGER, DINING_MANAGER
- Role embedded in JWT token
- Roles included in Spring Security authorities

✅ **Exception Handling**
- Custom exceptions for common scenarios
- Global exception handler for consistent responses
- Detailed error messages

✅ **CORS Support**
- Enabled for all origins (configurable for production)

✅ **Stateless Authentication**
- No server-side sessions
- JWT-based for scalability

---

## How to Use This Implementation

### 1. Build the Project
```bash
cd backend
mvn clean install
```

### 2. Run the Application
```bash
mvn spring-boot:run
```

### 3. Test the API
Use the provided TESTING.md for detailed test cases

### 4. Extend for Other Features
The authentication system is now foundation-ready for:
- Token purchase system
- Wallet management
- Marketplace functionality
- QR code generation
- Meal management endpoints
- Manager-specific features

---

## Architecture

### Clean Separation of Concerns
- **Models:** Database entities
- **Controllers:** HTTP request handling
- **Services:** Business logic
- **Repositories:** Data access
- **Security:** JWT and authentication
- **Config:** Spring configuration
- **Exception:** Error handling
- **DTO:** Data transfer objects

### Technology Stack
- **Framework:** Spring Boot 4.0.3
- **Security:** Spring Security 6.x
- **Database:** PostgreSQL
- **Token:** JWT (JJWT 0.12.3)
- **ORM:** Hibernate/JPA
- **Build Tool:** Maven
- **Language:** Java 21

---

## Future Enhancements

1. Add input validation (annotations)
2. Implement email OTP verification
3. Add token refresh mechanism
4. Implement rate limiting
5. Add audit logging
6. Implement password reset functionality
7. Add 2FA support
8. Create admin panel
9. Add API versioning
10. Implement API documentation (Swagger/OpenAPI)

---

This authentication system provides a solid, production-ready foundation for the Digital Dining Token Management System.
