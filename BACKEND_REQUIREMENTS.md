# CryptoArth Flutter Application - Project Status & Backend Requirements

## 1. Project Overview
CryptoArth is a premium, mobile-first algorithmic algorithmic trading app built in Flutter. The application allows users to create, backtest, and deploy AI-driven trading strategies, generate code in various languages (PineScript, Python, MQL4/5, AFL), access chat history, use templates, connect to a broker (Delta Exchange/CoinDCX), and monitor live PnL and portfolios. The app utilizes a sleek "Glassmorphism" UI and Riverpod for robust state management.

## 2. Completed Features (Frontend & API Integration)
The following modules have been successfully built, designed, and fully integrated with the existing backend APIs (`trade-api.cryptoarth.in`):

*   **Authentication Flow:** Send OTP, Verify Login, Signup, Session persistence, and OTP consumption.
*   **User Profile:** Viewing profile data and modifying it via partial updates (PATCH).
*   **Portfolio Management:**
    *   Toggling seamlessly between **Live** and **Paper** trading modes.
    *   Fetching live/paper positions (`/auth/get_user_positions/`, `/auth/user/positions/paper/`).
    *   Viewing consolidated broker balances.
*   **Order & Trade History:** Viewing categorized orders and trades (both live and paper) dynamically.
*   **Performance & PnL:** Real-time PnL summary fetching and dynamic PDF report generation.
*   **Marketplace & Strategy Dashboard:**
    *   Fetching global public strategies and user-specific portfolios.
    *   Strategy execution history visualization.
*   **Strategy Deployment:** Deploying and undeploying strategies to connected brokers via (`/auth/user/strategies/deploy/`).
*   **Backtesting Engine:** Configuring parameters, fetching lists, running copilot backtests, viewing candle data, and downloading results.
*   **Broker Integration:** Connecting Delta Exchange and CoinDCX via API keys.
*   **Payments & Credits:** Creating orders, verifying payments, checking balances, and viewing the ledger.

## 3. Pending Frontend Features (Work in Progress)
*   **Advanced AI Chat Integration:** Polishing the chat interface for AI-driven strategy generation.
*   **Deep Think & Improve Workflows:** Wiring up the AI modification UI widgets.
*   **Settings & Customization:** Adding extensive user preference switches and notification toggles.
*   **Error Handling & Edge Cases:** Broadening global error interceptors for 500s and network drops.

---

## 4. API Endpoints Needed from Backend Team (Action Required)
To make the application fully "Production Ready," we identified a few missing endpoints or features during development. We are currently "mocking" these on the frontend to prevent app crashes.

### 4.1. Strategy Access Control & Sharing (High Priority)
Currently, users can click "Edit" or "Share" on their backtested strategies to change visibility (Limited, Public, Shared) or share it directly with a specific phone number.
*   **Missing Endpoint:** `PATCH /auth/strategy/backtest/detail/`
*   **Purpose:** To update the `access_type` and `shared_with` list of an existing strategy.
*   **Expected Request:**
    ```json
    // PATCH /auth/strategy/backtest/detail/?strategy_code=STRG-8AC3B2
    {
      "access_type": "Shared", 
      "shared_with": ["9158912169"] 
    }
    ```
*   **Current State:** The backend returns `405 Method Not Allowed`. The frontend is currently faking a 500ms success delay.

### 4.4. Strategy Deletion (Medium Priority)
Users need the ability to delete old or failed backtests/strategies from their execution history.
*   **Missing Endpoint:** `DELETE /auth/strategy/backtest/detail/`
*   **Expected Request:** `DELETE /auth/strategy/backtest/detail/?strategy_code=STRG-XXXX`
*   **Current State:** Not implemented on backend.

### 4.5. AI-Powered Code Generation (High Priority)
The "Code Generator" module is currently using static mock templates. To be production-ready, this needs to generate actual executable code based on the user's specific strategy logic.
*   **Proposed Endpoint:** `POST /auth/strategy/generate-code/`
*   **Body:** `{ "strategy_code": "...", "language": "Pine|Python|MQL4|AFL" }`
*   **Response:** `{ "code": "..." }`

### 4.6. Remote Configuration & Environment Keys (Low Priority)
Currently, secondary keys (like Razorpay Client IDs for Payments) are hardcoded in the Flutter source.
*   **Requirement:** An endpoint or extension to `/auth/profile/` or `/health/` that returns public configuration keys.
*   **Keys needed:** `razorpay_key`, `mixpanel_id`, etc.

### 4.7. Deployment Parameterization (Low Priority)
Actual strategy deployment needs to support custom parameters per user.
*   **Requirement:** Update `POST /auth/user/strategies/deploy/` to accept:
    *   `capital`: Amount to allocate.
    *   `leverage`: Multiplier.
    *   `risk_per_trade`: Percentage (%) of capital per order.

### 4.8. Account Deletion (High Priority)
For compliance (GDPR/App Store), the app must allow users to delete their account data.
*   **Proposed Endpoint:** `DELETE /auth/profile/` or `POST /auth/user/delete/`
*   **Purpose:** Permanently remove user data and active strategy deployments.

### 4.9. Connected Brokers List (Medium Priority)
Currently, some deployment flows assume a hardcoded `broker_id`. To be dynamic, we need an endpoint to fetch which brokers the user has successfully connected.
*   **Proposed Endpoint:** `GET /auth/user/brokers/`
*   **Response:** `[{ "id": 1, "name": "Delta Exchange", "status": "active" }, ...]`

## 5. Summary Table for Backend Team

| Feature | Method | Endpoint Path | Priority | Status |
|---------|--------|---------------|----------|--------|
| Strategy Update | PATCH | `/auth/strategy/backtest/detail/` | ⭐ High | Mocked |
| Code Generation | POST | `/auth/strategy/generate-code/` | ⭐ High | Mocked |
| Share Strategy | PATCH | `/auth/strategy/backtest/detail/` | ⭐ High | Mocked |
| Account Deletion | DELETE | `/auth/profile/` | ⭐ High | Missing |
| Broker List | GET | `/auth/user/brokers/` | 🟦 Med | Missing |
| Delete Strategy | DELETE | `/auth/strategy/backtest/detail/` | 🟦 Med | Missing |
| AI Improve | POST | `/auth/strategy/copilot/optimize/` | 🟦 Med | Missing |
| Remote Config | GET | `/auth/config/` | 🟨 Low | Hardcoded |

---
*Document prepared for CryptoArth Backend Team. Generated by Antigravity AI.*
