# Digital Dining Token Management System

---

# 1. Introduction

## 1.1 Purpose
This document describes the functional and non-functional requirements of the Digital Dining Token Management System, a mobile-based application designed to digitalize the traditional physical token-based dining system used in university halls.  
This SRS serves as a reference for developers, stakeholders, and project supervisors.

## 1.2 Scope
The system will:

- Replace physical dining tokens with digital tokens.  
- Introduce hall-based digital wallets (coins).  
- Allow students to purchase dining tokens digitally.  
- Provide a marketplace for reselling tokens.  
- Use QR code verification during meal distribution.  

Support three user roles:

- General Student  
- Meal Manager  
- Dining Manager  

Each university hall operates independently with its own:

- Wallet system  
- Dining system  
- Token pricing  
- Management  

## 1.3 Definitions

| Term | Definition |
|------|------------|
| Token | Digital representation of a meal (Lunch/Dinner) |
| Coin | Digital wallet balance used to purchase tokens |
| Hall | University residential hall with independent dining |
| Marketplace | Platform for token resale between students |
| QR Code | Time-limited verification code for meal validation |

---

# 2. Overall Description

## 2.1 Product Perspective
The system consists of:

- Frontend: Flutter Mobile Application  
- Backend: Spring Boot REST API  
- Database: PostgreSQL  

It is a standalone system but may integrate with university email server for OTP verification.

## 2.2 Product Functions
At a high level, the system will:

- Authenticate users via email and password.  
- Allow students to maintain digital wallets.  
- Allow token purchase for next day only.  
- Allow token resale via marketplace.  
- Generate QR codes for meal validation.  
- Allow managers to monitor and control dining operations.  

## 2.3 User Classes

### 1. General Student
- Purchase tokens  
- Use tokens  
- Trade tokens  
- View wallet balance  
- View transaction history  

### 2. Meal Manager
- Top up wallet coins  
- Set menu for next day  
- Set token price  
- Set purchase deadline  
- Monitor token sales  

### 3. Dining Manager
- Scan QR codes  
- Validate tokens  
- Record meal distribution  

## 2.4 Operating Environment
- Android mobile devices  
- REST API server  
- PostgreSQL database server  

## 2.5 Constraints
- Token purchase allowed only for next day.  
- Token cancellation is not allowed.  
- Marketplace transactions use real money outside the app.  
- Each hall is economically independent.  
- QR codes must be time-limited and secure.  

---

# 3. Functional Requirements

## 3.1 Authentication Module

**FR-1: Signup**  
Student can set initial password.  
OTP verification must be sent to university email.  

**FR-2: Login**  
User must provide:  
- Email  
- Password  

System must redirect to role-based dashboard.  

**FR-3: Password Security**  
Password must be stored in encrypted format.  

---

## 3.2 Wallet Management

**FR-4: Wallet Creation**  
Each student automatically has a wallet for their hall.  

**FR-5: Top-Up**  
Meal Manager can:  
- Add coin balance  
- Record transaction  
- View sold tokens  

**FR-6: View Balance**  
Student can view current coin balance.  

---

## 3.3 Token Purchase System

**FR-7: Buy Token**  
Student can:  
- Purchase token only for next day.  
- One student can only purchase 1 token  
- Choose:  
  - Lunch  
  - Dinner  
  - Both  
- Purchase only from own hall.  

**FR-8: Purchase Deadline**  
Purchase must be blocked after deadline set by Meal Manager.  

**FR-9: Token Deduction**  
Coin must be deducted instantly.  
Token record must be created.  

---

## 3.4 Marketplace System

**FR-10: Create Sell Request**  
Student can post token for sale.  
Only unused future tokens allowed.  

**FR-11: View Sell Requests**  
Students can see list of active sell posts and sellers info  

**FR-12: Buy Request**  
Student can request to buy a token.  

**FR-13: Token Transfer**  
After real money exchange,  
Seller confirms transfer.  
Ownership updated in database.  

---

## 3.5 QR Meal Validation

**FR-14: Generate QR**  
Student can click "Use Token".  
System generates time-limited QR.  

**FR-15: Scan QR**  
Dining Manager scans QR.  
Backend validates:  
- Token exists  
- Correct date  
- Correct meal type  
- Not already used  

**FR-16: Mark as Used**  
If valid:  
- Token marked as USED.  
- Entry saved in meal history.  

---

## 3.6 Meal Management

**FR-17: Set Menu**  
Meal Manager can:  
- Set next day lunch menu  
- Set next day dinner menu  

**FR-18: Set Token Price**  
Set price for lunch and dinner separately.  

**FR-19: Set Purchase Deadline**  
Define time limit for token purchase.  

**FR-20: View Sales Report**  
View number of tokens sold (Lunch/Dinner).  
View total revenue.  

---

# 4. Non-Functional Requirements

## 4.1 Performance
API response time < 2 seconds.  
Must support at least 1000 users per hall.  

## 4.2 Security
- Password hashing (BCrypt).  
- JWT-based authentication.  
- Role-based access control.  
- Prevent double usage of token.  
- Secure QR validation.  

## 4.3 Reliability
Database consistency during:  
- Token purchase  
- Token transfer  
- QR validation  

No duplicate token creation allowed.  

## 4.4 Usability
- Simple UI for dining manager.  
- Clear wallet and token information for students.  
- Minimal steps for token purchase.  

## 4.5 Maintainability
- Modular backend structure.  
- Role-based separation.  
- Independent hall logic.  

---

# 5. System Models

## 5.1 Use Case Overview

### Student Use Cases
- Login  
- Buy Token  
- Sell Token  
- Buy from Marketplace  
- Generate QR  
- View Transactions  

### Meal Manager Use Cases
- Top-up Wallet  
- Set Menu  
- Set Price  
- View Reports  

### Dining Manager Use Cases
- Scan QR  
- Validate Token  
- View Meal Records  

---

# 6. Data Requirements

Main Entities:

- User  
- Hall  
- Wallet  
- Token  
- MarketplacePost  
- Transaction  
- Menu  
- QRSession  

---

# 7. Business Rules

- Token valid only for specific date and meal.  
- Token cannot be canceled.  
- Token cannot be used twice.  
- Coin cannot be transferred between halls.  
- Marketplace does not process real money.  
- Only future unused tokens can be sold.  

---

# 8. Assumptions & Dependencies

- Student database already exists.  
- University email system is operational.  
- Internet connection is available in dining hall.  
- Dining manager device has camera.  

---

# 9. Future Enhancements

- Online payment gateway integration.  
- Push notifications.  
- Admin super panel.  
- Multi-hall analytics dashboard.  
- Real-time chat system for marketplace.  

---

# Conclusion

The Digital Dining Token Management System will replace the existing physical token system with a secure, scalable, and efficient digital solution, improving transparency, reducing fraud, and simplifying dining operations across university halls.