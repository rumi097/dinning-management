# Postman API Testing Guide — Digital Dining Token System

## A Complete Beginner's Guide (Step-by-Step with Every Button)

---

## Table of Contents

1. [What is Postman?](#1-what-is-postman)
2. [Download & Install Postman](#2-download--install-postman)
3. [First Launch — Understanding the Postman Screen](#3-first-launch--understanding-the-postman-screen)
4. [How to Create Your First Request (Step-by-Step)](#4-how-to-create-your-first-request-step-by-step)
5. [Setting Up Environment Variables](#5-setting-up-environment-variables)
6. [Start Your Backend Server](#6-start-your-backend-server)
7. [API Endpoints — Step-by-Step for Each Request](#7-api-endpoints--step-by-step-for-each-request)
   - [7.1 Admin APIs (No Login Needed)](#71-admin-apis-no-login-needed)
   - [7.2 Auth APIs (Registration & Login)](#72-auth-apis-registration--login)
   - [7.3 Marketplace APIs (Requires Login)](#73-marketplace-apis-requires-login)
8. [Complete Testing Walkthrough — Full Scenario](#8-complete-testing-walkthrough--full-scenario)
9. [Quick Reference — All Endpoints](#9-quick-reference--all-endpoints)
10. [Common Errors & How to Fix Them](#10-common-errors--how-to-fix-them)

---

## 1. What is Postman?

Postman is a free app that lets you **send requests** to your backend server and **see the response**. Think of it like a web browser, but instead of loading web pages, it sends data to your API and shows you what comes back.

**Why do we need it?**
- Your backend (Spring Boot) runs on `http://localhost:8080` but has no web page
- Postman lets you talk to the backend directly — send data, get data back
- You can test every API endpoint without needing the Flutter app

---

## 2. Download & Install Postman

### Step 1: Go to the download page
Open your browser and go to: **https://www.postman.com/downloads/**

### Step 2: Download
- Click the big orange **"Download the App"** button (it auto-detects macOS)
- A `.zip` file will start downloading

### Step 3: Install
- Open your **Downloads** folder
- Double-click the `.zip` file → it extracts the **Postman** app
- Drag the **Postman** icon into your **Applications** folder
- Double-click **Postman** in Applications to launch it

### Step 4: Create a free account (or skip)
- Postman will ask you to sign in or create an account
- You can click **"Skip and go to the app"** at the bottom (no account needed for local testing)

---

## 3. First Launch — Understanding the Postman Screen

When Postman opens, here's what you see:

```
┌─────────────────────────────────────────────────────────────────────┐
│  [Postman Logo]    Home   Workspaces   API Network        [Sign In]│
├──────────┬──────────────────────────────────────────────────────────┤
│          │  ┌─ Tab Bar ──────────────────────────────────────┐     │
│          │  │  + (New Tab)    Untitled Request               │     │
│ Sidebar  │  ├───────────────────────────────────────────────┤     │
│          │  │ [GET ▼]  [Enter URL here              ] [Send]│     │
│ - Collec │  ├───────────────────────────────────────────────┤     │
│ - Enviro │  │  Params | Auth | Headers | Body | ...         │     │
│ - Histor │  │                                               │     │
│          │  │  (Request settings area)                      │     │
│          │  ├───────────────────────────────────────────────┤     │
│          │  │  Response area (shows results after Send)     │     │
│          │  │  Body | Cookies | Headers | Test Results      │     │
│          │  └───────────────────────────────────────────────┘     │
└──────────┴──────────────────────────────────────────────────────────┘
```

### Key Parts of the Screen:

| Part | Where | What it does |
|------|-------|-------------|
| **Method Dropdown** | Top-left, says `GET` | Click to change between GET, POST, PUT, DELETE |
| **URL Bar** | Long text field next to the method | Type the API URL here (e.g., `http://localhost:8080/api/v1/admin/users`) |
| **Send Button** | Blue button on the right of URL bar | Click to send the request to the server |
| **Params Tab** | Below URL bar | Add query parameters (like `?email=test@test.com`) |
| **Auth Tab** | Below URL bar | Set authentication (JWT token goes here) |
| **Headers Tab** | Below URL bar | Add custom headers (like `X-User-Id`) |
| **Body Tab** | Below URL bar | Add request body (JSON data for POST requests) |
| **Response Area** | Bottom half of screen | Shows the server's response after you click Send |
| **Sidebar** | Left panel | Shows your saved collections, environments, history |

---

## 4. How to Create Your First Request (Step-by-Step)

Let's make a simple GET request to see all users.

### Step 1: Open a new tab
- Click the **`+`** button in the tab bar at the top
- A new request tab opens with "Untitled Request"

### Step 2: Choose the HTTP method
- Look at the top-left — there's a dropdown that says **`GET`**
- For this example, leave it as **`GET`**
- (For other requests, click this dropdown and select `POST`, `PUT`, `DELETE`, etc.)

### Step 3: Type the URL
- Click the **URL bar** (the long text field that says "Enter URL or paste text")
- Type: `http://localhost:8080/api/v1/admin/users`

### Step 4: Click Send
- Click the blue **`Send`** button on the right side of the URL bar
- Wait a moment...

### Step 5: Read the response
- The **bottom half** of the screen will show the response
- Look at:
  - **Status**: Green `200 OK` means success (shown top-right of response area)
  - **Body tab**: Shows the JSON data the server sent back
  - **Time**: How long the request took (shown next to status)

**Congratulations!** You just made your first API request!

---

## 5. Setting Up Environment Variables

Environment variables let you save values (like your base URL and JWT token) so you don't have to type them every time. You use `{{variable_name}}` in your requests, and Postman replaces it with the saved value.

### Step 1: Create a new environment

1. Look at the **top-right corner** of Postman — there's a dropdown that says **"No Environment"**
2. Click the **eye icon** (👁) next to that dropdown
3. A panel opens — click **"Add"** at the bottom
   
   **OR (Alternative way):**
   - Click the **"Environments"** tab in the left sidebar
   - Click the **`+`** button to create a new environment

### Step 2: Name the environment
- In the name field at the top, type: **`Dining Token Local`**

### Step 3: Add variables
You'll see a table with columns: **VARIABLE**, **TYPE**, **INITIAL VALUE**, **CURRENT VALUE**

Add these rows (click in each cell and type):

| VARIABLE | TYPE | INITIAL VALUE | CURRENT VALUE |
|----------|------|---------------|---------------|
| `base_url` | default | `http://localhost:8080/api/v1` | `http://localhost:8080/api/v1` |
| `jwt_token` | default | *(leave empty)* | *(leave empty)* |
| `user_id` | default | *(leave empty)* | *(leave empty)* |

### Step 4: Save the environment
- Click the **`Save`** button (top-right of the environment editor, or press `Ctrl+S` / `Cmd+S`)

### Step 5: Select the environment
- Go back to the main screen
- In the **top-right corner**, click the environment dropdown (it says "No Environment")
- Select **"Dining Token Local"** from the list

### Step 6: Use variables in your requests
Now instead of typing `http://localhost:8080/api/v1`, you can type `{{base_url}}`:
- In the URL bar, type: `{{base_url}}/admin/users`
- Postman will automatically replace `{{base_url}}` with `http://localhost:8080/api/v1`
- You'll see `{{base_url}}` highlighted in orange — that means it found the variable

---

## 6. Start Your Backend Server

Before testing any API, your Spring Boot server must be running.

### Step 1: Open Terminal
- Open **Terminal** app on your Mac (press `Cmd + Space`, type "Terminal", press Enter)

### Step 2: Navigate to the project
```bash
cd /Users/aliazgorrumi/Development/checking/backend
```

### Step 3: Start the server
```bash
./mvnw spring-boot:run
```

### Step 4: Wait for startup
- Wait until you see: **`Started DsiApplication`** (or similar) in the terminal
- The server is now running on `http://localhost:8080`
- **Keep this terminal open!** Closing it stops the server.

### Step 5: Make sure PostgreSQL is running
- PostgreSQL must be running on `localhost:5432` with database `dsiApp`
- If you're using Homebrew: `brew services start postgresql`

---

## 7. API Endpoints — Step-by-Step for Each Request

> **Base URL for all requests:** `http://localhost:8080/api/v1`  
> Or use the variable: `{{base_url}}`

---

### 7.1 Admin APIs (No Login Needed)

These endpoints are **public** — you don't need any JWT token or special headers. They are used by admins to create user accounts.

---

#### 7.1.1 Add User (Create an Account for a Student)

This creates a new user account. The user still needs to verify OTP and sign up with a password later.

**Follow these steps in Postman:**

1. **Click `+`** in the tab bar to open a new request tab

2. **Click the method dropdown** (says `GET`) and **select `POST`**

3. **Click the URL bar** and type:
   ```
   {{base_url}}/admin/add-user
   ```

4. **Click the `Headers` tab** (below the URL bar)
   - In the first empty row:
     - **Key** column: type `Content-Type`
     - **Value** column: type `application/json`
   - (This tells the server we're sending JSON data)

5. **Click the `Body` tab** (next to Headers tab)
   - You'll see radio buttons: `none`, `form-data`, `x-www-form-urlencoded`, `raw`, `binary`, `GraphQL`
   - **Click `raw`**
   - A dropdown appears on the right showing `Text` — **click it and select `JSON`**
   - In the text area below, type this JSON:
   ```json
   {
       "email": "rumi@student.ruet.ac.bd",
       "hallId": 1,
       "role": "STUDENT"
   }
   ```

6. **Click the blue `Send` button**

7. **Check the response** (bottom half of screen):
   - **Status**: Should show `200 OK` (in green)
   - **Body**: Shows the created user data:
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
- `hallId` must match an existing hall (halls are auto-created when the server starts)
- `role` can be: `STUDENT`, `MEAL_MANAGER`, or `DINING_MANAGER`
- The user gets a placeholder password — they'll set a real one during sign-up

---

#### 7.1.2 Get User by Email

Look up a user's info by their email address.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab

2. **Leave the method as `GET`** (default)

3. **Click the URL bar** and type:
   ```
   {{base_url}}/admin/user?email=rumi@student.ruet.ac.bd
   ```
   > The `?email=...` part is a "query parameter" — it tells the server which user to look up

4. **Click the blue `Send` button**

5. **Check the response:**
   - Status: `200 OK`
   - Body:
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

> **Tip:** Instead of typing the query parameter in the URL, you can use the **Params** tab:
> 1. Type just `{{base_url}}/admin/user` in the URL bar
> 2. Click the **`Params`** tab
> 3. In the **Key** column, type `email`
> 4. In the **Value** column, type `rumi@student.ruet.ac.bd`
> 5. Postman will automatically add `?email=rumi@student.ruet.ac.bd` to the URL

---

#### 7.1.3 Get All Users

See a list of every user in the system.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Leave the method as `GET`**
3. **Type in URL bar:** `{{base_url}}/admin/users`
4. **Click `Send`**
5. **Response** shows an array of all users:
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

#### 7.1.4 Delete User by Email

Remove a user from the system.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Click the method dropdown** and **select `DELETE`**
3. **Type in URL bar:** `{{base_url}}/admin/user?email=test@student.ruet.ac.bd`
4. **Click `Send`**
5. **Response:**
   ```json
   {
       "success": true,
       "message": "User deleted successfully",
       "data": null
   }
   ```

---

### 7.2 Auth APIs (Registration & Login)

These APIs handle the sign-up and login flow. The process is:

```
Step 1: Admin adds user (7.1.1)
     ↓
Step 2: User requests OTP (7.2.1)
     ↓
Step 3: User verifies OTP (7.2.2)
     ↓
Step 4: User signs up with password (7.2.3)
     ↓
Step 5: User logs in → gets JWT token (7.2.4) ⭐
     ↓
Step 6: Use JWT token for all protected requests
```

---

#### 7.2.1 Send OTP (Request a Verification Code)

This sends a one-time password (OTP) to the user's email.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Click the method dropdown** → select **`POST`**
3. **Type in URL bar:**
   ```
   {{base_url}}/auth/send-otp?email=rumi@student.ruet.ac.bd
   ```
4. **Click `Send`**
5. **Response:**
   ```json
   {
       "message": "OTP sent successfully",
       "email": "rumi@student.ruet.ac.bd",
       "success": true
   }
   ```

> **Important:** The OTP is sent by email. If email is not configured on your server, look at your **Terminal** where the server is running — the OTP will be printed in the server console logs. Copy that number!

---

#### 7.2.2 Verify OTP

Confirm the OTP code that was sent.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Click the method dropdown** → select **`POST`**
3. **Type in URL bar** (replace `123456` with the actual OTP from the server logs):
   ```
   {{base_url}}/auth/verify-otp?email=rumi@student.ruet.ac.bd&otp=123456
   ```
   > The `&` separates multiple query parameters: `email` and `otp`

4. **Click `Send`**
5. **Response:**
   ```json
   {
       "message": "OTP verified successfully",
       "email": "rumi@student.ruet.ac.bd",
       "verified": true
   }
   ```

---

#### 7.2.3 Sign Up (Set Password and Profile)

After verifying OTP, the user completes their profile with a password.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Click the method dropdown** → select **`POST`**
3. **Type in URL bar:** `{{base_url}}/auth/signup`

4. **Click the `Headers` tab:**
   - **Key:** `Content-Type`
   - **Value:** `application/json`

5. **Click the `Body` tab:**
   - **Click `raw`**
   - **Click the dropdown on the right → select `JSON`**
   - Type this JSON (change the values to match your user):
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

6. **Click `Send`**
7. **Response:**
   ```json
   {
       "message": "User registered successfully",
       "email": "rumi@student.ruet.ac.bd",
       "userId": 1
   }
   ```

**Important:** Before signing up, you must have:
- Created the user via Admin add-user (section 7.1.1)
- Verified the OTP (section 7.2.2)

---

#### 7.2.4 Login ⭐ (Get Your JWT Token)

This is the **most important request** — it gives you the JWT token needed for all protected endpoints.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Click the method dropdown** → select **`POST`**
3. **Type in URL bar:** `{{base_url}}/auth/login`

4. **Click the `Headers` tab:**
   - **Key:** `Content-Type`
   - **Value:** `application/json`

5. **Click the `Body` tab:**
   - **Click `raw`**
   - **Click the dropdown → select `JSON`**
   - Type:
   ```json
   {
       "email": "rumi@student.ruet.ac.bd",
       "password": "MyPassword123"
   }
   ```

6. **Click `Send`**

7. **Read the response carefully:**
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

8. **⭐ SAVE TWO VALUES from the response:**
   - **`token`** — this is your JWT token (a long string starting with "eyJ...")
   - **`userId`** — this is your user ID number

### How to Save the Token and User ID in Postman:

**Method A: Manually save to environment variables**

1. In the response body, find the `"token"` value (the long string starting with `eyJ...`)
2. **Select and copy** the entire token string (without the quotes)
3. Click the **eye icon** (👁) in the top-right corner (next to environment dropdown)
4. Find the `jwt_token` row
5. Click in the **CURRENT VALUE** column and **paste** the token
6. Do the same for `user_id` — copy the number from the response and paste it
7. Click outside the panel or press `Esc` to close

**Method B: Automatically save using a script (recommended)**

1. In the Login request tab, click the **`Scripts`** tab (below the URL bar, after Body)
   - In older Postman versions, this tab is called **`Tests`**
2. Click on **`Post-response`** (the sub-tab on the right)
   - In older versions, this is just the Tests tab itself
3. In the text area, paste this code:
   ```javascript
   if (pm.response.code === 200) {
       var jsonData = pm.response.json();
       pm.environment.set("jwt_token", jsonData.token);
       pm.environment.set("user_id", jsonData.userId);
       console.log("JWT Token saved:", jsonData.token);
       console.log("User ID saved:", jsonData.userId);
   }
   ```
4. Click **`Save`** (or `Cmd+S`)
5. Now every time you click Send on this login request, your token and user ID will be automatically saved!

---

#### 7.2.5 Get Current User (Test Your Token)

Use this to verify your JWT token is working.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Leave the method as `GET`**
3. **Type in URL bar:** `{{base_url}}/auth/me`

4. **Click the `Auth` tab** (below the URL bar):
   - You'll see a **"Type"** dropdown — it might say "Inherit auth from parent" or "No Auth"
   - **Click the Type dropdown** and select **`Bearer Token`**
   - A text field labeled **"Token"** appears
   - Type: `{{jwt_token}}`
   - (Postman will replace this with the actual token you saved earlier)

5. **Click `Send`**

6. **Response:**
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

> If you get `401 Unauthorized`, your token is expired or wrong. Go back to 7.2.4 and login again.

---

### 7.3 Marketplace APIs (Requires Login)

> **Every marketplace request needs TWO things:**
>
> **Thing 1 — JWT Token** (proves you're logged in):
> - Click the **`Auth`** tab
> - Type dropdown → select **`Bearer Token`**
> - Token field → type `{{jwt_token}}`
>
> **Thing 2 — X-User-Id header** (tells the marketplace who you are):
> - Click the **`Headers`** tab
> - Add a new row:
>   - **Key:** `X-User-Id`
>   - **Value:** `{{user_id}}`
>
> **You must do both of these for EVERY marketplace request below!**

---

#### 7.3.1 Get My Available Tokens

See which tokens you own that could be sold.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Leave the method as `GET`**
3. **Type in URL bar:** `{{base_url}}/marketplace/my-tokens`

4. **Click the `Auth` tab:**
   - Type → **`Bearer Token`**
   - Token → `{{jwt_token}}`

5. **Click the `Headers` tab:**
   - Add a row: Key = `X-User-Id`, Value = `{{user_id}}`

6. **Click `Send`**

7. **Response:**
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

> **Note the `id` values** (like `1`, `2`) — you'll need these to sell a token in the next step.

---

#### 7.3.2 Create Sell Post (List a Token for Sale)

Put one of your tokens up for sale on the marketplace.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Click the method dropdown** → select **`POST`**
3. **Type in URL bar:** `{{base_url}}/marketplace/sell`

4. **Click the `Auth` tab:**
   - Type → **`Bearer Token`**
   - Token → `{{jwt_token}}`

5. **Click the `Headers` tab:**
   - Row 1: Key = `Content-Type`, Value = `application/json`
   - Row 2: Key = `X-User-Id`, Value = `{{user_id}}`

6. **Click the `Body` tab:**
   - Click **`raw`**
   - Click dropdown → select **`JSON`**
   - Type (use a token ID from step 7.3.1):
   ```json
   {
       "tokenId": 1
   }
   ```

7. **Click `Send`**

8. **Response:**
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

> The **post `id`** in the response (here it's `1`) is what buyers will use to buy this token.

---

#### 7.3.3 Get Open Marketplace Posts (Browse Available Tokens)

See all tokens for sale in your hall.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Leave the method as `GET`**
3. **Type in URL bar:** `{{base_url}}/marketplace/posts`

4. **Click the `Auth` tab:**
   - Type → **`Bearer Token`**
   - Token → `{{jwt_token}}`

5. **Click the `Headers` tab:**
   - Add a row: Key = `X-User-Id`, Value = `{{user_id}}`

6. **Click `Send`**

7. **Response** — all open listings from your hall (excludes your own posts):
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
               "status": "OPEN"
           }
       ]
   }
   ```

---

#### 7.3.4 Send Buy Request

Request to buy someone's token. The seller must confirm before the deal is complete.

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Click the method dropdown** → select **`POST`**
3. **Type in URL bar:** `{{base_url}}/marketplace/buy`

4. **Click the `Auth` tab:**
   - Type → **`Bearer Token`**
   - Token → `{{jwt_token}}`

5. **Click the `Headers` tab:**
   - Row 1: Key = `Content-Type`, Value = `application/json`
   - Row 2: Key = `X-User-Id`, Value = `{{user_id}}`

6. **Click the `Body` tab:**
   - Click **`raw`** → select **`JSON`**
   - Type one of these options:

   **Option A — Pay with in-app wallet credit:**
   ```json
   {
       "postId": 1,
       "paymentType": "TRANSACTION"
   }
   ```

   **Option B — Pay externally (cash/bKash, handled outside the app):**
   ```json
   {
       "postId": 1,
       "paymentType": "TOPUP"
   }
   ```
   > Replace `1` with the actual post ID from section 7.3.3

7. **Click `Send`**

8. **Response:**
   ```json
   {
       "success": true,
       "message": "Buy request sent — seller has 15 min to confirm",
       "data": {
           "id": 1,
           "status": "PENDING",
           "buyerId": 2,
           "buyerName": "Karim Hassan",
           "paymentType": "TRANSACTION",
           "buyerRequestedAt": "2026-03-02T15:35:00"
       }
   }
   ```

**Payment Type Explained:**

| Value | What it means | What happens when seller confirms |
|-------|--------------|-----------------------------------|
| `TRANSACTION` | Pay with in-app credit | Money is automatically moved from buyer's wallet to seller's wallet |
| `TOPUP` | Pay externally (cash, bKash, etc.) | No wallet transfer — you handle payment outside the app |

---

#### 7.3.5 Confirm Transfer (Seller Approves the Sale)

**This must be done by the SELLER (the person who listed the token).**

> You need to be logged in as the seller. If you were testing as the buyer, you need to login as the seller first (go to 7.2.4 and login with the seller's credentials — this will update your `jwt_token` and `user_id`).

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Click the method dropdown** → select **`POST`**
3. **Type in URL bar** (replace `1` with the actual post ID):
   ```
   {{base_url}}/marketplace/listings/1/confirm
   ```

4. **Click the `Auth` tab:**
   - Type → **`Bearer Token`**
   - Token → `{{jwt_token}}`

5. **Click the `Headers` tab:**
   - Add a row: Key = `X-User-Id`, Value = `{{user_id}}`

6. **Click `Send`**

7. **Response:**
   ```json
   {
       "success": true,
       "message": "Token transferred successfully",
       "data": {
           "id": 1,
           "status": "COMPLETED",
           "sellerId": 1,
           "buyerId": 2,
           "paymentType": "TRANSACTION"
       }
   }
   ```

**What happens when you confirm:**
- The token's ownership transfers from seller to buyer
- If `TRANSACTION`: buyer's wallet is debited, seller's wallet is credited (the meal price amount)
- If `TOPUP`: no wallet transfer (payment is handled outside the app)
- Token status goes back to `AVAILABLE` (owned by buyer now)

---

#### 7.3.6 Reject Buy Request (Seller Says No)

**This must be done by the SELLER.**

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Method** → **`POST`**
3. **URL:** `{{base_url}}/marketplace/listings/1/reject` (replace `1` with post ID)
4. **Auth tab:** Type → `Bearer Token`, Token → `{{jwt_token}}`
5. **Headers tab:** Key = `X-User-Id`, Value = `{{user_id}}`
6. **Click `Send`**
7. **Response:**
   ```json
   {
       "success": true,
       "message": "Buy request rejected",
       "data": {
           "id": 1,
           "status": "OPEN",
           "buyerId": null,
           "buyerName": null
       }
   }
   ```

> The post goes back to OPEN status so other people can buy it.

---

#### 7.3.7 Cancel Buy Request (Buyer Changes Their Mind)

**This must be done by the BUYER.**

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Method** → **`POST`**
3. **URL:** `{{base_url}}/marketplace/purchases/1/cancel` (replace `1` with post ID)
4. **Auth tab:** Type → `Bearer Token`, Token → `{{jwt_token}}`
5. **Headers tab:** Key = `X-User-Id`, Value = `{{user_id}}`
6. **Click `Send`**
7. **Response:**
   ```json
   {
       "success": true,
       "message": "Buy request cancelled",
       "data": {
           "id": 1,
           "status": "OPEN",
           "buyerId": null,
           "buyerName": null
       }
   }
   ```

---

#### 7.3.8 Cancel Listing (Seller Removes Their Post)

**This must be done by the SELLER.** Cannot be done if someone has a pending buy request (reject it first).

**Follow these steps in Postman:**

1. **Click `+`** to open a new request tab
2. **Method** → **`DELETE`**
3. **URL:** `{{base_url}}/marketplace/1` (replace `1` with post ID)
4. **Auth tab:** Type → `Bearer Token`, Token → `{{jwt_token}}`
5. **Headers tab:** Key = `X-User-Id`, Value = `{{user_id}}`
6. **Click `Send`**
7. **Response:**
   ```json
   {
       "success": true,
       "message": "Listing cancelled",
       "data": null
   }
   ```

> The token goes back to AVAILABLE status in the seller's account.

---

#### 7.3.9 Get My Listings (See Your Sale Posts)

See all the tokens you've listed for sale.

**Follow these steps in Postman:**

1. **Click `+`** → **Method: `GET`**
2. **URL:** `{{base_url}}/marketplace/my-listings`
3. **Auth tab:** Type → `Bearer Token`, Token → `{{jwt_token}}`
4. **Headers tab:** Key = `X-User-Id`, Value = `{{user_id}}`
5. **Click `Send`**
6. **Response:**
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
               "sellerName": "Rumi Ahmed",
               "buyerName": null
           }
       ]
   }
   ```

---

#### 7.3.10 Get My Purchases (See Your Buy Requests)

See all the buy requests you've made.

**Follow these steps in Postman:**

1. **Click `+`** → **Method: `GET`**
2. **URL:** `{{base_url}}/marketplace/my-purchases`
3. **Auth tab:** Type → `Bearer Token`, Token → `{{jwt_token}}`
4. **Headers tab:** Key = `X-User-Id`, Value = `{{user_id}}`
5. **Click `Send`**
6. **Response:**
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
               "sellerName": "Rumi Ahmed",
               "buyerName": "Karim Hassan",
               "paymentType": "TRANSACTION"
           }
       ]
   }
   ```

---

## 8. Complete Testing Walkthrough — Full Scenario

This walks you through testing the entire marketplace flow from scratch. **Do each step in order.**

---

### Scenario: User A sells a token, User B buys it

You'll need **two user accounts**. Follow every step carefully.

---

#### Phase 1: Create User A (the Seller)

**Step 1 — Admin creates User A:**
1. Open new tab → **POST** → `{{base_url}}/admin/add-user`
2. Headers: `Content-Type: application/json`
3. Body (raw, JSON):
   ```json
   {
       "email": "seller@student.ruet.ac.bd",
       "hallId": 1,
       "role": "STUDENT"
   }
   ```
4. Click Send → Note the response

**Step 2 — Send OTP to User A:**
1. New tab → **POST** → `{{base_url}}/auth/send-otp?email=seller@student.ruet.ac.bd`
2. Click Send
3. **Go to your Terminal** where the server is running → look for the OTP code in the logs → **copy it**

**Step 3 — Verify OTP for User A:**
1. New tab → **POST** → `{{base_url}}/auth/verify-otp?email=seller@student.ruet.ac.bd&otp=PASTE_OTP_HERE`
2. Click Send → Should say "OTP verified successfully"

**Step 4 — Sign up User A:**
1. New tab → **POST** → `{{base_url}}/auth/signup`
2. Headers: `Content-Type: application/json`
3. Body (raw, JSON):
   ```json
   {
       "email": "seller@student.ruet.ac.bd",
       "password": "Seller123!",
       "name": "Seller User",
       "roll": "2103001",
       "phoneNo": "01700000001",
       "roomNo": "101"
   }
   ```
4. Click Send

**Step 5 — Login as User A:**
1. New tab → **POST** → `{{base_url}}/auth/login`
2. Headers: `Content-Type: application/json`
3. Body (raw, JSON):
   ```json
   {
       "email": "seller@student.ruet.ac.bd",
       "password": "Seller123!"
   }
   ```
4. Click Send
5. **From the response, write down:**
   - `token` value → this is **Token-A**
   - `userId` value → this is **UserID-A**
6. If you set up the auto-save script (section 7.2.4), these are already saved

---

#### Phase 2: See User A's Tokens and Sell One

**Step 6 — See User A's tokens:**
1. New tab → **GET** → `{{base_url}}/marketplace/my-tokens`
2. Auth tab: Type = `Bearer Token`, Token = `{{jwt_token}}` (or paste Token-A)
3. Headers: `X-User-Id` = `{{user_id}}` (or type UserID-A)
4. Click Send
5. **Write down a token `id`** from the response (e.g., `1`)

**Step 7 — List that token for sale:**
1. New tab → **POST** → `{{base_url}}/marketplace/sell`
2. Auth tab: Type = `Bearer Token`, Token = `{{jwt_token}}`
3. Headers: `Content-Type: application/json` AND `X-User-Id: {{user_id}}`
4. Body (raw, JSON):
   ```json
   {
       "tokenId": 1
   }
   ```
   > Replace `1` with the token ID from Step 6
5. Click Send
6. **Write down the marketplace post `id`** from the response (e.g., `1`)

---

#### Phase 3: Create User B (the Buyer) and Login

**Step 8 — Repeat Steps 1-5 for User B:**
- Admin add user with email `buyer@student.ruet.ac.bd`
- Send OTP, verify OTP, sign up, login
- **From the login response, write down:**
  - `token` value → this is **Token-B**
  - `userId` value → this is **UserID-B**

> **Important:** When you login as User B, the environment variables `jwt_token` and `user_id` will be updated to User B's values (if you have the auto-save script). This means your next requests will automatically use User B's credentials.

---

#### Phase 4: User B Buys the Token

**Step 9 — User B browses marketplace:**
1. New tab → **GET** → `{{base_url}}/marketplace/posts`
2. Auth tab: Type = `Bearer Token`, Token = `{{jwt_token}}` (Token-B)
3. Headers: `X-User-Id` = `{{user_id}}` (UserID-B)
4. Click Send
5. You should see User A's listing in the response

**Step 10 — User B sends buy request:**
1. New tab → **POST** → `{{base_url}}/marketplace/buy`
2. Auth tab: Type = `Bearer Token`, Token = `{{jwt_token}}`
3. Headers: `Content-Type: application/json` AND `X-User-Id: {{user_id}}`
4. Body (raw, JSON):
   ```json
   {
       "postId": 1,
       "paymentType": "TRANSACTION"
   }
   ```
   > Replace `1` with the post ID from Step 7
5. Click Send → Status should be "PENDING"

---

#### Phase 5: User A Confirms the Sale

**Step 11 — Login as User A again:**
1. Go back to the Login request tab
2. Change the body to User A's email and password:
   ```json
   {
       "email": "seller@student.ruet.ac.bd",
       "password": "Seller123!"
   }
   ```
3. Click Send → The environment variables update to User A's credentials

**Step 12 — User A confirms the transfer:**
1. New tab → **POST** → `{{base_url}}/marketplace/listings/1/confirm` (replace `1` with post ID)
2. Auth tab: Bearer Token → `{{jwt_token}}`
3. Headers: `X-User-Id` = `{{user_id}}`
4. Click Send → "Token transferred successfully"

---

#### Phase 6: Verify the Transfer Worked

**Step 13 — Login as User B, check tokens:**
1. Login as User B again (section 7.2.4)
2. New tab → **GET** → `{{base_url}}/marketplace/my-tokens`
3. Auth/Headers as usual
4. Click Send
5. **The token User A sold should now appear in User B's token list!**

---

### Alternative Scenarios to Test

**Reject Flow:**
| Step | What to do | Who |
|------|-----------|-----|
| 1 | Sell a token (7.3.2) | User A |
| 2 | Buy request (7.3.4) | User B |
| 3 | Login as User A and Reject (7.3.6) | User A |
| 4 | Check posts — listing is OPEN again (7.3.3) | Anyone |

**Cancel Flow:**
| Step | What to do | Who |
|------|-----------|-----|
| 1 | Sell a token (7.3.2) | User A |
| 2 | Buy request (7.3.4) | User B |
| 3 | Cancel request (7.3.7) | User B |
| 4 | Check posts — listing is OPEN again (7.3.3) | Anyone |

**Remove Listing:**
| Step | What to do | Who |
|------|-----------|-----|
| 1 | Sell a token (7.3.2) | User A |
| 2 | Delete listing (7.3.8) | User A |
| 3 | Check my-tokens — token is AVAILABLE again (7.3.1) | User A |

---

## 9. Quick Reference — All Endpoints

| # | Method | URL | Auth Needed? | Body |
|---|--------|-----|-------------|------|
| 1 | POST | `/api/v1/admin/add-user` | No | `{ email, hallId, role }` |
| 2 | GET | `/api/v1/admin/users` | No | — |
| 3 | GET | `/api/v1/admin/user?email=` | No | — |
| 4 | DELETE | `/api/v1/admin/user?email=` | No | — |
| 5 | POST | `/api/v1/auth/send-otp?email=` | No | — |
| 6 | POST | `/api/v1/auth/verify-otp?email=&otp=` | No | — |
| 7 | POST | `/api/v1/auth/signup` | No | `{ email, password, name, roll, phoneNo, roomNo }` |
| 8 | POST | `/api/v1/auth/login` | No | `{ email, password }` |
| 9 | GET | `/api/v1/auth/me` | JWT only | — |
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

---

## 10. Common Errors & How to Fix Them

### "Could not send request" / "Connection refused"

**Problem:** Postman can't reach the server.

**Fix:**
1. Check that your backend server is running in Terminal (`./mvnw spring-boot:run`)
2. Check that you see "Started DsiApplication" in the terminal output
3. Make sure the URL starts with `http://localhost:8080`

---

### "401 Unauthorized"

**Problem:** The server doesn't recognize who you are.

**Fix:**
1. Make sure you've logged in first (section 7.2.4)
2. Check the **Auth** tab in your request:
   - Type must be **Bearer Token**
   - Token field must have `{{jwt_token}}` (or the actual token string)
3. Check the environment is selected (top-right dropdown should say "Dining Token Local")
4. Your token might be expired — login again to get a new one

---

### "403 Forbidden"

**Problem:** You're logged in but don't have permission.

**Fix:**
- Make sure you're using the right user account
- Some endpoints are only for specific roles (STUDENT, MEAL_MANAGER, etc.)

---

### "User not found" (400 or 404)

**Problem:** The `X-User-Id` header has a wrong value.

**Fix:**
1. Go to the **Headers** tab
2. Check that `X-User-Id` has the correct user ID number
3. Use `{{user_id}}` to automatically use the saved value
4. If unsure, call `GET {{base_url}}/admin/users` to see all user IDs

---

### "Token not found" (400)

**Problem:** The token ID in your request body doesn't exist.

**Fix:**
1. First call `GET {{base_url}}/marketplace/my-tokens` to see your actual token IDs
2. Use one of those IDs in your request

---

### "Post not found" (400)

**Problem:** The marketplace post ID doesn't exist.

**Fix:**
1. First call `GET {{base_url}}/marketplace/posts` to see all available posts
2. Use a post ID from that response

---

### "Cannot buy your own token" (400)

**Problem:** You're trying to buy a token that you listed for sale.

**Fix:** Login as a **different user** to buy the token.

---

### "Insufficient balance" (400)

**Problem:** Your wallet doesn't have enough credit for `TRANSACTION` payment type.

**Fix:**
- Use `"paymentType": "TOPUP"` instead (pay externally)
- Or top up your wallet first

---

### "Post is not OPEN" (400)

**Problem:** Someone already sent a buy request for this token.

**Fix:** Refresh the posts list (`GET /marketplace/posts`) and try a different post.

---

### Response shows HTML instead of JSON

**Problem:** You're getting an error page instead of API data.

**Fix:**
1. Check your URL — make sure it starts with `{{base_url}}` or `http://localhost:8080/api/v1`
2. Don't add `/api/v1` twice (it's already in the base URL)
3. Check for typos in the endpoint path

---

### Body tab is empty / "Could not get response"

**Problem:** The server might have crashed or the request timed out.

**Fix:**
1. Check your Terminal — is the server still running?
2. If the server crashed, restart it: `./mvnw spring-boot:run`
3. Make sure PostgreSQL is running

---

## Tips & Tricks for Postman

### Save Your Requests
- Click **`Save`** (Cmd+S) after setting up a request
- Postman will ask you to create a **Collection** — think of it as a folder
- Name it "Dining Token API"
- Next time you open Postman, all your saved requests are in the sidebar

### Create Folders in a Collection
1. Right-click your collection name in the sidebar
2. Click **"Add Folder"**
3. Create folders like: `Admin`, `Auth`, `Marketplace`
4. Drag your saved requests into the right folders

### Duplicate a Request (saves time!)
1. Right-click a saved request in the sidebar
2. Click **"Duplicate"**
3. Now you can modify the copy instead of creating from scratch
4. This is useful because marketplace requests all need the same Auth + Headers setup

### View Request History
- Click **"History"** in the left sidebar
- It shows every request you've sent, even unsaved ones
- Click any history item to re-open it

### Use the Console for Debugging
- Click **"Console"** at the bottom of Postman (or press `Cmd + Alt + C`)
- Shows detailed request/response info including headers and timing
- Your auto-save script's `console.log` messages appear here too
