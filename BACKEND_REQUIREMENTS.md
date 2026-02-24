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

### 4.1. Strategy Access Control & Sharing (INTEGRATED)
Now integrated with the updated backend endpoints.
*   **Endpoint:** `POST /auth/strategy/backtest/edit/`
*   **Purpose:** Updates `access_type`, `strategy_name`, `description`, and other metadata.
*   **Share Endpoint:** `POST /auth/strategy/backtest/share/`

### 4.4. Strategy Deletion (INTEGRATED)
Now integrated with the updated backend endpoint.
*   **Endpoint:** `POST /auth/strategy/delete/`
*   **Expected Request:** `{ "strategy_code": "STRG-XXXX" }`

### 4.5. AI-Powered Code Generation (PARTIALLY INTEGRATED)
Now supports fetching Pine Scripture from:
*   **Endpoint:** `GET /auth/strategy/backtest/pine-code/`
*   **Coming Soon:** Full code conversion for MQL4/Python/AFL using copilot endpoints.

### 4.8. Account Deletion (High Priority)
For compliance (GDPR/App Store), the app must allow users to delete their account data.
*   **Proposed Endpoint:** `DELETE /auth/profile/` or `POST /auth/user/delete/`
*   **Current State:** Still missing on backend.

### 4.9. Connected Brokers List (Medium Priority)
Currently, some deployment flows assume a hardcoded `broker_id`. To be dynamic, we need an endpoint to fetch which brokers the user has successfully connected.
*   **Proposed Endpoint:** `GET /auth/user/brokers/`
*   **Current State:** Still missing on backend.

### 4.10. Deep Strategy Analytics (New Requirement)
The "Premium High-Fidelity Report" needs an enhanced data structure.
*   **Endpoint:** `GET /auth/strategy/backtest/result/`
*   **Required Data Fields:**
    *   `equity_curve`: List of `{ "x": trade_number, "y": balance }` for interactive charting.
    *   `trade_statistics`: Detailed metrics (Best/Worst trade, Sharpe, Sortino, Profit Factor, R/R).
    *   `time_analysis`: Best/Worst hour and day performance breakdown.
    *   `yearly_performance`: Map of years (e.g., "2025", "2026") with Trades, P&L, and Win Rate.
    *   `trades_list`: Detailed history of individual entries/exits within the backtest.

## 5. Summary Table for Backend Team

| Feature | Method | Endpoint Path | Priority | Status |
|---------|--------|---------------|----------|--------|
| Strategy Update | POST | `/auth/strategy/backtest/edit/` | ⭐ High | **Integrated** |
| Share Strategy | POST | `/auth/strategy/backtest/share/` | ⭐ High | **Integrated** |
| Delete Strategy | POST | `/auth/strategy/delete/` | 🟦 Med | **Integrated** |
| AI Chat/History | POST/GET | `/auth/strategy/copilot/chat/` | ⭐ High | **Integrated** |
| Profile Update | PATCH | `/auth/profile/` | ⭐ High | **Integrated** |
| Pine Code Fetch | GET | `/auth/strategy/backtest/pine-code/` | ⭐ High | **Integrated** |
| Account Deletion | DELETE | `/auth/profile/` | ⭐ High | Missing |
| Broker List | GET | `/auth/user/brokers/` | 🟦 Med | Missing |
| Deep Analytics | GET | `/auth/strategy/backtest/result/` | ⭐ High | Documentation Sent |
| Remote Config | GET | `/auth/config/` | 🟨 Low | Hardcoded |

---
*Document updated with latest integration status. Generated by Antigravity AI.*
