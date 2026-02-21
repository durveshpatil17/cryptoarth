# CryptoArth Backend â€“ API Documentation

Complete reference for **Crypto_Arth_Backend** APIs. Use this for Flutter mobile app or any client integration. No backend code was changed.

---

## 1. API Base URL & Health

- **Local development:** `http://127.0.0.1:8000`
- **Staging / Production:** `https://trade-api.cryptoarth.in`

- **Health check (no auth):** `GET /health/` â†’ response body: `"ok"`

---

## 2. Authentication Overview

### 2.1 Method
- **Type:** JWT (Bearer token)
- **Header:** `Authorization: Bearer <access_token>`
- **Access token lifetime:** 1440 minutes (24 hours)
- **Refresh token lifetime:** 1 day
- **Token rotation:** Refresh tokens are rotated when used (`ROTATE_REFRESH_TOKENS: True`)

### 2.2 Logout
- There is **no server-side logout endpoint**
- **Logout = discard** the access token (and optionally refresh token) on the client

---

## 3. Authentication APIs (Points)

### 3.1 Send OTP
- **Endpoint:** `POST /auth/send-otp/`
- **Auth required:** No
- **Request body (JSON):**
  - `phone` (string) â€“ 10-digit mobile number, e.g. `"9876543210"`
- **Success:** 200 â€“ OTP sent
- **Error:** 4xx with message in body

### 3.2 Verify OTP / Login
- **Endpoint:** `POST /auth/login/`
- **Auth required:** No
- **Request body (JSON):**
  - `phone` (string)
  - `otp` (string) â€“ 6-digit OTP
- **Success (200):** Returns:
  - `message` â€“ e.g. "Login successful."
  - `access` â€“ JWT access token (use in Bearer header)
  - `refresh` â€“ JWT refresh token
  - `user_id` â€“ numeric user ID
  - `redirect_url` â€“ optional hint for frontend

### 3.3 Signup (new user)
- **Endpoint:** `POST /auth/signup/`
- **Auth required:** No
- **Request body (JSON):**
  - `phone` (string)
  - `otp` (string)
  - `email` (string)
  - `first_name` (string)
  - `last_name` (string)
  - `refercode` (string, optional)
- **Note:** User is created only here; `/auth/send-otp/` does not create users.
- **Success (200):** Same shape as login (`access`, `refresh`, etc.)

### 3.4 Consume OTP
- **Endpoint:** `POST /auth/consume-otp/`
- **Auth required:** Yes (Bearer)
- **Request body:** Empty `{}` or no body
- **Purpose:** Clear OTP from cache after successful login/signup. Always returns 200.

### 3.5 Session check
- **Endpoint:** `GET /auth/session/`
- **Auth required:** Yes (Bearer)
- **Success (200):** `user.id`, `user.username`, `user.is_mobile_app`, `expires`

---

## 4. Profile APIs (Points)

### 4.1 Get profile
- **Endpoint:** `GET /auth/profile/` or `GET /auth/user/`
- **Auth required:** Yes (Bearer)
- **Success (200):** User object (id, email, phone, first_name, last_name, is_login, broker, flags, etc.). Sensitive fields (e.g. api_key) are not returned.

### 4.2 Update profile
- **Endpoint:** `PATCH /auth/profile/` or `PATCH /auth/user/`
- **Auth required:** Yes (Bearer)
- **Request body (JSON):** Any subset of: `first_name`, `last_name`, `email`, etc.
- **Success (200):** Updated user object

---

## 5. Portfolio / Positions (Points)

### 5.1 Live positions
- **Endpoint:** `GET /auth/get_user_positions/`
- **Auth required:** Yes (Bearer)
- **Success (200):** Array of position objects (live trading)

### 5.2 Paper positions
- **Endpoint:** `GET /auth/user/positions/paper/`
- **Auth required:** Yes (Bearer)
- **Success (200):** Array of paper trade positions

### 5.3 Broker balance
- **Endpoint:** `GET /auth/broker/balance/`
- **Auth required:** Yes (Bearer)
- **Success (200):** Balance info from all connected brokers (structure may vary by broker)

---

## 6. Orders & Trades (Points)

### 6.1 Orders (live)
- **Endpoint:** `GET /auth/orders/`
- **Auth required:** Yes (Bearer)
- **Returns:** Order details for current user (today range by default)

### 6.2 Orders (paper)
- **Endpoint:** `GET /auth/orders/paper/`
- **Auth required:** Yes (Bearer)

### 6.3 Trades (live)
- **Endpoint:** `GET /auth/trades/`
- **Auth required:** Yes (Bearer)

### 6.4 Trades (paper)
- **Endpoint:** `GET /auth/trades/paper/`
- **Auth required:** Yes (Bearer)

### 6.5 User order details
- **Endpoint:** `GET /auth/userOrderDetails/`
- **Auth required:** Yes (Bearer)

---

## 7. PnL Report (Points)

### 7.1 PnL summary
- **Endpoint:** `GET /auth/get_user_pnl/`
- **Auth required:** Yes (Bearer)
- **Success (200):** JSON with:
  - `today_profit` â€“ today P&L
  - `total_profit` â€“ all-time P&L
  - `trades` â€“ count of open positions (from broker APIs)

### 7.2 PnL report PDF
- **Endpoint:** `GET /auth/pl-report/pdf/`
- **Auth required:** Yes (Bearer)
- **Returns:** PDF file (Content-Type: application/pdf). Query params as per backend for date range.

---

## 8. Strategies (Points)

### 8.1 User strategies / portfolio
- **Endpoint:** `GET /auth/user/strategies/` or `GET /auth/strategies/`
- **Auth required:** Yes (Bearer)
- **Returns:** User strategy portfolio list

### 8.2 Deployed strategies (codes only)
- **Endpoint:** `GET /auth/strategies/deployed/`
- **Auth required:** Yes (Bearer)
- **Success (200):** `{ "success": true, "data": [ { "strategy_code", "strategy_name" }, ... ] }`

### 8.3 Deploy strategy
- **Endpoint:** `POST /auth/user/strategies/deploy/`
- **Auth required:** Yes (Bearer)
- **Body:** e.g. `strategyid`, `user_id`, `broker_id` (as per backend)

### 8.4 Undeploy strategy
- **Endpoint:** `POST /auth/user/strategies/undeploy/`
- **Auth required:** Yes (Bearer)
- **Body:** e.g. `strategyid` (as per backend)

### 8.5 Backtest â€“ list strategies
- **Endpoint:** `GET /auth/strategy/backtest/list/`
- **Auth required:** Yes (Bearer)
- **Query params (optional):**
  - `type=marketplace` â€“ public strategies
  - `type=my-strategy` â€“ own strategies
  - `type=shared` â€“ shared with user
  - `lite=1` â€“ lighter response

### 8.6 Backtest â€“ detail & result
- **Detail:** `GET /auth/strategy/backtest/detail/` (query: backtest_id or strategy_code)
- **Result status:** `GET /auth/strategy/backtest/result/` (for polling backtest job)
- **Auth required:** Yes (Bearer) for both

### 8.7 Dashboard / Marketplace strategies
- **Endpoint:** `GET /auth/strategy/dashboard/`
- **Auth required:** Yes (Bearer)
- **Returns:** Strategies for dashboard/marketplace (own, shared, public)
- **Query params (optional):** `lite=1`, `cards=1`

---

## 9. Backtest (Extra endpoints)

- `POST /auth/strategy/copilot/prepare-backtest/` â€“ prepare backtest
- `POST /auth/strategy/copilot/backtest/` â€“ run backtest
- `GET /auth/strategy/backtest/detail/chart/` â€“ chart data
- `GET /auth/strategy/backtest/detail/report/` â€“ report
- `GET /auth/backtest/candles/` â€“ candle data
- `GET /auth/backtest-symbols/` â€“ symbol mappings  
All require **Bearer** auth.

---

## 10. Broker Connection (Points)

### 10.1 Connect broker (Delta Exchange)
- **Endpoint:** `POST /auth/broker/connect/`
- **Auth required:** Yes (Bearer)
- **Request body (JSON):** `api_key`, `api_secret`
- **Success (200):** Broker linked to user
- **Error (400):** Invalid credentials, KYC not done, or login disabled

### 10.2 Test broker (no save)
- **Endpoint:** `POST /auth/diagnostic/`
- **Auth required:** Yes (Bearer)
- **Request body (JSON):** `api_key`, `api_secret`, `broker` (e.g. "Coindcx" or Delta)
- **Purpose:** Validate credentials without saving

### 10.3 Connect CoinDCX
- **Endpoint:** `POST /auth/connect/coindcx/`
- **Auth required:** Yes (Bearer)
- **Body:** api_key, api_secret (as per backend)

---

## 11. Dashboard (Admin / Staff only)

- **POST** `/auth/dashboard/` â€“ body: `startdate`, `enddate`
- **POST** `/auth/dashboardcount/` â€“ body: `startDate`, `endDate`
- **GET** `/auth/today_dashboardcount/`  
All require **Bearer** and **staff** permission. For regular app users, use Profile, Portfolio, Orders, PnL, and Strategies (and Marketplace) as the main dashboard data.

---

## 12. Payments & Credits (Points)

- **Create order:** `POST /auth/payment/create-order/`
- **Verify payment:** `POST /auth/payment/verify/`
- **Credit balance:** `GET /auth/payment/balance/`
- **Ledger:** `GET /auth/payment/ledger/`  
All require **Bearer** auth.

---

## 13. Notifications & Other (Points)

### 13.1 Notifications
- **Endpoint:** `GET /auth/notifications/` or `GET /auth/userNotifications/`
- **Auth required:** Yes (Bearer)

### 13.2 Check phone
- **Endpoint:** `POST /auth/check-phone/`
- **Body:** `{ "phone": "9876543210" }`
- **Auth required:** No

### 13.3 Watchlist
- **Endpoint:** `GET /auth/watchlist/`
- **Auth required:** Yes (Bearer)

### 13.4 Referral link
- **Endpoint:** `GET /auth/get_referal_link/`
- **Auth required:** Yes (Bearer)

---

## 14. Test Credentials & Staging

- **Test credentials:** The backend does **not** define built-in test users or test OTP in code. To test:
  1. Use a real or test mobile number.
  2. Call `POST /auth/send-otp/` with that phone.
  3. Use the OTP received (or any test OTP if configured in your environment) in `POST /auth/login/`.
- **Staging server:** Use your deployed backend base URL. Same API paths and Bearer auth. Ensure CORS and ALLOWED_HOSTS allow your Flutter app origin.

---

## 15. Quick Reference Table

| Category        | Method | Endpoint                         | Auth   |
|----------------|--------|----------------------------------|--------|
| Health         | GET    | /health/                         | No     |
| Send OTP       | POST   | /auth/send-otp/                  | No     |
| Login          | POST   | /auth/login/                     | No     |
| Signup         | POST   | /auth/signup/                    | No     |
| Consume OTP    | POST   | /auth/consume-otp/               | Bearer |
| Session        | GET    | /auth/session/                   | Bearer |
| Profile        | GET    | /auth/profile/                   | Bearer |
| Profile update | PATCH  | /auth/profile/                   | Bearer |
| Positions      | GET    | /auth/get_user_positions/        | Bearer |
| Paper positions| GET    | /auth/user/positions/paper/      | Bearer |
| Broker balance | GET    | /auth/broker/balance/            | Bearer |
| Orders         | GET    | /auth/orders/                    | Bearer |
| Orders paper   | GET    | /auth/orders/paper/              | Bearer |
| Trades         | GET    | /auth/trades/                    | Bearer |
| PnL            | GET    | /auth/get_user_pnl/              | Bearer |
| PnL PDF        | GET    | /auth/pl-report/pdf/             | Bearer |
| Strategies     | GET    | /auth/user/strategies/           | Bearer |
| Deployed       | GET    | /auth/strategies/deployed/       | Bearer |
| Deploy         | POST   | /auth/user/strategies/deploy/    | Bearer |
| Undeploy       | POST   | /auth/user/strategies/undeploy/  | Bearer |
| Backtest list  | GET    | /auth/strategy/backtest/list/    | Bearer |
| Marketplace    | GET    | /auth/strategy/dashboard/        | Bearer |
| Broker connect | POST   | /auth/broker/connect/            | Bearer |
| Notifications  | GET    | /auth/notifications/             | Bearer |

---

Use the **Postman collection** (`CryptoArth_Backend_Postman_Collection.json`) for ready-to-run requests and variables (`base_url`, `access_token`).
