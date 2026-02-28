# CryptoArth Backend - Complete API Documentation

## API Base URL & Health

- **Local development:** `http://127.0.0.1:8000`
- **Staging / Production:** `https://trade-api.cryptoarth.in`

- **Health check (no auth):** `GET /health/` â†’ response body: `"ok"`

**Base URL:** http://127.0.0.1:8000 (local) or your deployed host.
**Auth:** JWT Bearer. Header: Authorization: Bearer <access_token>. Access token: 24h. Refresh: 1 day. No server-side logout.

---

## 1. Health and Admin

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /health/ | No |
| (Django) | /admin/ | Admin site |

---

## 2. Authentication

| Method | Endpoint | Auth |
|--------|----------|------|
| POST | /auth/send-otp/ | No |
| POST | /auth/login/ | No |
| POST | /auth/signup/ | No |
| POST | /auth/consume-otp/ | Bearer |
| GET | /auth/session/ | Bearer |
| GET | /auth/diagnostic/ | Bearer |
| POST | /auth/diagnostic/ | Bearer (test broker, no save) |

---

## 3. Profile and User

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/profile/ | Bearer |
| PATCH | /auth/profile/ | Bearer |
| GET | /auth/user/ | Bearer |
| PATCH | /auth/user/ | Bearer |
| POST | /auth/check-phone/ | No |
| GET | /auth/users/phone/<phone>/ | Staff |

---

## 4. Portfolio and Positions

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/get_user_positions/ | Bearer |
| GET | /auth/user/positions/paper/ | Bearer |
| POST | /auth/user/open_position/ | Bearer |

---

## 5. Broker

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/broker/balance/ | Bearer |
| POST | /auth/broker/connect/ | Bearer |
| POST | /auth/broker/connect1/ | Bearer |
| POST | /auth/connect/coindcx/ | Bearer |

---

## 6. Orders and Trades

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/orders/ | Bearer |
| GET | /auth/orders/paper/ | Bearer |
| GET | /auth/trades/ | Bearer |
| GET | /auth/trades/paper/ | Bearer |
| GET | /auth/userOrderDetails/ | Bearer |

---

## 7. PnL and Reports

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/get_user_pnl/ | Bearer |
| GET | /auth/pl-report/pdf/ | Bearer |
| GET | /strategy/pnl/ | Bearer |

---

## 8. Strategies (User)

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/user/strategies/ | Bearer |
| GET | /auth/strategies/ | Bearer |
| GET | /auth/strategies/deployed/ | Bearer |
| POST | /auth/user/strategies/deploy/ | Bearer |
| POST | /auth/user/strategies/undeploy/ | Bearer |
| GET | /auth/strategy/dashboard/ | Bearer |
| GET | /auth/strategy/backtest/list/ | Bearer |
| POST | /auth/user/add_strategy/ | Bearer |
| GET | /auth/user/user_strategy/ | Bearer |
| GET | /auth/user/admin_user_strategy/ | Bearer |
| POST | /auth/user_strategy_set/ | Bearer |
| GET | /auth/get_strategy_data/ | Bearer |
| GET | /strategy/user-strategy/ | Bearer |
| GET | /strategy/user/ | Bearer |

---

## 9. Execution History (Panel Buttons)

| Button | Method | Endpoint | Auth |
|--------|--------|----------|------|
| Backtest | GET | /auth/strategy/backtest/detail/ (query: strategy_code) | Bearer |
| Chart | GET | /auth/strategy/backtest/detail/chart/ (query: strategy_code) | Bearer |
| Edit | POST | /auth/strategy/backtest/edit/ (body: strategy_code + optional fields) | Bearer |
| Pine | GET | /auth/strategy/backtest/pine-code/ (query: strategy_code) | Bearer |
| Report | GET | /auth/strategy/backtest/detail/report/ (query: strategy_code) | Bearer |
| Share give | POST | /auth/strategy/backtest/share/ (body: strategy_code, user_id) | Bearer |
| Share remove | DELETE | /auth/strategy/backtest/share/ (body: strategy_code, user_id) | Bearer |
| Share list | GET | /auth/strategy/backtest/share/ (query: strategy_code) | Bearer |
| Improve | POST | /auth/strategy/improve/ (body: strategy_code) | Bearer |
| Improve quote | POST | /auth/strategy/improve/quote/ (body: strategy_code) | Bearer |
| Deep Think v1 | POST | /auth/strategy/deep-think-optimize/ | Bearer |
| Deep Think v2 | POST | /auth/strategy/deep-think-optimize-v2/ | Bearer |
| Deep Think v2 status | GET | /auth/strategy/deep-think-optimize-v2/status/ | Bearer |
| Deep Think v2 sync | POST | /auth/strategy/deep-think-optimize-v2/sync/ | Bearer |
| PDF | GET | /auth/strategy/backtest/report/<uuid:backtest_id>/ | Bearer |
| Delete | POST | /auth/strategy/delete/ (body: strategy_code) | Bearer |

---

## 10. Backtest (Full)

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/strategy/backtest/result/ | Bearer |
| POST | /auth/strategy/copilot/prepare-backtest/ | Bearer |
| POST | /auth/strategy/copilot/backtest/ | Bearer |
| POST | /auth/strategy/copilot/save-strategy/ | Bearer |
| POST | /auth/strategy/backtest/deploy/ | Bearer |
| POST | /auth/strategy/backtest/trade-mode/ | Bearer |
| POST | /auth/strategy/backtest/validate/ | Bearer |
| POST | /auth/strategy/backtest/indicators/ | Bearer |
| GET | /auth/strategy/backtest/check-open-position/ (query: strategy_code) | Bearer |
| POST | /auth/strategy/rerun-backtest/ | Bearer |
| POST | /auth/strategy/update-name/ | Bearer |
| POST | /auth/strategy/sync-deployed/ | Bearer |
| GET | /auth/strategy/check-deployment-sync/ | Bearer |
| GET | /auth/backtest/candles/ (query: symbol, timeframe) | Bearer |
| GET | /auth/backtest-symbols/ | Bearer |

---

## 11. Share and Access

| Method | Endpoint | Auth |
|--------|----------|------|
| POST | /auth/add_user_to_strategy/ | Bearer |
| POST | /auth/remove_user_to_strategy/ | Bearer |
| GET | /auth/strategy/users/<strategy_id>/detailed/ | Bearer |

---

## 12. Copilot and Strategy Builder

| Method | Endpoint | Auth |
|--------|----------|------|
| POST | /auth/strategy/copilot/chat/ | Bearer |
| POST | /auth/strategy/copilot/stream/ | Bearer |
| GET | /auth/strategy/copilot/history/ | Bearer |
| GET | /auth/strategy/copilot/fetch-conversions/ | Bearer |
| POST | /auth/strategy/copilot/code-conversion/ | Bearer |
| POST | /auth/strategy/copilot/smart-convert/ | Bearer |
| POST | /auth/strategy/copilot/smart-convert-test/ | Bearer |
| POST | /auth/strategy/copilot/convert/ | Bearer |
| POST | /auth/strategy/copilot/convert-test/ | Bearer |
| GET | /strategy/templates/ | Bearer |
| GET | /api/strategy-aitemplates/ | Bearer |
| POST | /auth/strategy/ai/generate-strategy/ | Bearer |
| GET | /auth/strategy/ai/generate-strategy/status/ | Bearer |
| GET | /auth/strategy/ai/health/ | Bearer |

---

## 13. Payments and Credits

| Method | Endpoint | Auth |
|--------|----------|------|
| POST | /auth/payment/create-order/ | Bearer |
| POST | /auth/payment/verify/ | Bearer |
| GET | /auth/payment/balance/ | Bearer |
| GET | /auth/payment/ledger/ | Bearer |
| GET | /auth/payment/invoice/<invoice_id>/ | Bearer |
| POST | /auth/payment/test-email/ | Bearer |
| POST | /auth/payment/webhook/ | Server |
| POST | /payment/webhook/razorpay/ | Public webhook |

---

## 14. Signals

| Method | Endpoint | Auth |
|--------|----------|------|
| POST | /auth/signal/ | Bearer |
| POST | /auth/copy-signal/ | Bearer |
| POST | /auth/internal-signal/ | Bearer |
| POST | /auth/setSignal/ | Bearer |
| POST | /auth/deleteSignal/ | Bearer |
| POST | /auth/editActiveSignal/ | Bearer |
| POST | /auth/edidPendingSignal/ | Bearer |
| POST | /auth/closeSignal/ | Bearer |
| GET | /auth/signal-list/ | Bearer |
| GET | /auth/copystrategyshow/ | Bearer |

---

## 15. Tutorials

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/tutorials/ | Bearer |
| GET | /auth/tutorials/<pk>/ | Bearer |
| GET | /auth/tutorial-ai/ | Bearer |
| POST | /auth/tutorial-ai/generate/ | Bearer |
| POST | /auth/tutorial-ai/generate-all/ | Bearer |
| GET | /auth/get_tutorial/ | Bearer |

---

## 16. Admin (Staff)

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/admin/notifications/ | Staff |
| GET | /auth/admin/fail-orders/ | Staff |
| GET | /auth/get_admin_strategy_list/ | Staff |
| GET | /auth/get_admin_user_list/ | Staff |
| POST | /auth/get_admin_broker_list/ (body: user_id) | Staff |
| POST | /auth/admin_deploy_user_strategy/ | Staff |
| POST | /auth/admin_undeploy_user_strategy/ | Staff |
| GET | /auth/get_admin_strategy_data/ | Staff |
| POST | /auth/edit_user/ | Staff |
| POST | /auth/change_margin_moode/ | Staff |
| GET | /auth/admin/strategies/deployed/ | Staff |
| GET | /auth/adminPositionDetails/ | Staff |
| GET | /auth/admin/open-positions/ | Staff |
| GET | /auth/adminOrderDetails/ | Staff |
| GET | /auth/adminTradeDetails/ | Staff |
| POST | /auth/admin/close_position/ | Staff |
| POST | /auth/admin/close_positions_by_strategy/ | Staff |
| POST | /auth/admin/auto-close-position/ | Staff |
| POST | /auth/admin/auto-close-positions/ | Staff |
| POST | /auth/admin/fail-orders/ | Staff |
| GET/POST | /auth/admin/candle-loader/ | Staff |
| GET | /auth/admin/candle-loader/mappings/ | Staff |
| GET/PUT/DELETE | /auth/admin/candle-loader/mappings/<mapping_id>/ | Staff |
| GET | /auth/admin/order-rules/<phone>/ | Staff |
| GET/DELETE | /auth/admin/order-rules/<phone>/<pk>/ | Staff |
| GET | /auth/admin/strategy-monitor/ | Staff |
| POST | /auth/admin/strategy-monitor/detail/ | Staff |
| POST | /auth/admin/strategy-monitor/deploy/ | Staff |
| POST | /auth/admin/strategy-monitor/update/ | Staff |
| GET | /auth/admin/credits/lookup/ | Staff |
| POST | /auth/admin/credits/add/ | Staff |
| POST | /auth/admin/credits/deduct/ | Staff |
| POST | /auth/admin/credits/correct/ | Staff |
| POST | /auth/admin_deactivate_strategy/ | Staff |
| POST | /auth/admin_activate_strategy/ | Staff |
| POST | /auth/admin_strategy_set/ | Staff |

---

## 17. Positions Close and Margin

| Method | Endpoint | Auth |
|--------|----------|------|
| POST | /auth/close_open_position_onbroker/ | Bearer |
| POST | /auth/close_delta_position/ | Bearer |
| POST | /auth/close_coindcx_position/ | Bearer |
| POST | /auth/close_position_customer/ | Bearer |
| POST | /auth/Close_all_Positions/ | Bearer |
| POST | /auth/user/auto-close-position/ | Bearer |
| GET | /auth/get_margin_calculator/ | Bearer |
| GET | /auth/get_margin_calculator1/ | Bearer |

---

## 18. System and Monitoring (Staff)

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/system/performance/ | Staff |
| GET | /auth/system/api-latency-history/ | Staff |
| GET | /auth/system/backtest-queue/ | Staff |
| GET | /auth/system/top-endpoints/ | Staff |
| GET | /auth/system/errors/ | Staff |
| GET | /auth/system/error-logs/<error_id>/ | Staff |
| POST | /auth/system/error-logs/<error_id>/resolve/ | Staff |
| GET | /auth/system/registered-endpoints/ | Staff |
| GET | /auth/system/redis-detailed/ | Staff |
| GET | /auth/system/celery-workers/ | Staff |
| GET | /auth/system/cron-jobs/ | Staff |
| POST | /auth/system/cron-jobs/<job_name>/toggle/ | Staff |
| POST | /auth/system/cron-jobs/<job_name>/run/ | Staff |
| GET | /auth/system/strategy-engine/ | Staff |

---

## 19. Router (ViewSets) - under /auth/

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/highlow-strategies/ | Staff |
| POST | /auth/highlow-strategies/ | Staff |
| GET | /auth/highlow-strategies/<id>/ | Staff |
| PUT/PATCH | /auth/highlow-strategies/<id>/ | Staff |
| DELETE | /auth/highlow-strategies/<id>/ | Staff |
| GET | /auth/highlow-strategies1/ | Bearer |
| POST | /auth/highlow-strategies1/ | Bearer |
| GET | /auth/highlow-strategies1/<id>/ | Bearer |
| PUT/PATCH/DELETE | /auth/highlow-strategies1/<id>/ | Bearer |
| POST | /auth/highlow-strategies-limited/ | Bearer |
| GET | /auth/latency/ (query: strategy_code, strategy_name) | Staff |
| POST | /auth/latency/ | Staff |
| GET | /auth/latency/<id>/ | Staff |
| PUT/PATCH/DELETE | /auth/latency/<id>/ | Staff |

---

## 20. Other

| Method | Endpoint | Auth |
|--------|----------|------|
| GET | /auth/watchlist/ | Bearer |
| GET | /auth/get_referal_link/ | Bearer |
| GET | /auth/userNotifications/ | Bearer |
| GET | /auth/notifications/ | Bearer |
| POST | /auth/dashboard/ (body: startdate, enddate) | Staff |
| POST | /auth/dashboardcount/ (body: startDate, endDate) | Staff |
| GET | /auth/today_dashboardcount/ | Staff |

---

## 21. Master List - Every Endpoint (Alphabetical by Path)

Use this list to verify no endpoint is missing. Auth: N=None, B=Bearer, S=Staff.

| Endpoint | Method(s) | Auth |
|----------|-----------|------|
| /health/ | GET | N |
| /admin/ | - | Admin |
| /api/strategy-aitemplates/ | GET | B |
| /auth/add_user_to_strategy/ | POST | B |
| /auth/admin/auto-close-position/ | POST | S |
| /auth/admin/auto-close-positions/ | POST | S |
| /auth/admin/close_position/ | POST | S |
| /auth/admin/close_positions_by_strategy/ | POST | S |
| /auth/admin/credits/add/ | POST | S |
| /auth/admin/credits/correct/ | POST | S |
| /auth/admin/credits/deduct/ | POST | S |
| /auth/admin/credits/lookup/ | GET | S |
| /auth/admin/candle-loader/ | GET, POST | S |
| /auth/admin/candle-loader/mappings/ | GET | S |
| /auth/admin/candle-loader/mappings/<mapping_id>/ | GET, PUT, DELETE | S |
| /auth/admin/fail-orders/ | GET | S |
| /auth/admin/notifications/ | GET | S |
| /auth/admin/open-positions/ | GET | S |
| /auth/admin/order-rules/<phone>/ | GET | S |
| /auth/admin/order-rules/<phone>/<pk>/ | GET, DELETE | S |
| /auth/admin/strategies/deployed/ | GET | S |
| /auth/admin/strategy-monitor/ | GET | S |
| /auth/admin/strategy-monitor/detail/ | POST | S |
| /auth/admin/strategy-monitor/deploy/ | POST | S |
| /auth/admin/strategy-monitor/update/ | POST | S |
| /auth/admin_activate_strategy/ | POST | S |
| /auth/admin_deactivate_strategy/ | POST | S |
| /auth/admin_deploy_user_strategy/ | POST | S |
| /auth/admin_strategy_set/ | POST | S |
| /auth/admin_undeploy_user_strategy/ | POST | S |
| /auth/adminOrderDetails/ | GET | S |
| /auth/adminPositionDetails/ | GET | S |
| /auth/adminTradeDetails/ | GET | S |
| /auth/backtest/candles/ | GET | B |
| /auth/backtest-symbols/ | GET | B |
| /auth/broker/balance/ | GET | B |
| /auth/broker/connect/ | POST | B |
| /auth/broker/connect1/ | POST | B |
| /auth/change_margin_moode/ | POST | S |
| /auth/check-phone/ | POST | N |
| /auth/Close_all_Positions/ | POST | B |
| /auth/close_coindcx_position/ | POST | B |
| /auth/close_delta_position/ | POST | B |
| /auth/close_open_position_onbroker/ | POST | B |
| /auth/close_position_customer/ | POST | B |
| /auth/closeSignal/ | POST | B |
| /auth/connect/coindcx/ | POST | B |
| /auth/consume-otp/ | POST | B |
| /auth/copystrategyshow/ | GET | B |
| /auth/copy-signal/ | POST | B |
| /auth/dashboard/ | POST | S |
| /auth/dashboardcount/ | POST | S |
| /auth/deleteSignal/ | POST | B |
| /auth/diagnostic/ | GET, POST | B |
| /auth/editActiveSignal/ | POST | B |
| /auth/edidPendingSignal/ | POST | B |
| /auth/edit_user/ | POST | S |
| /auth/get_admin_broker_list/ | POST | S |
| /auth/get_admin_strategy_data/ | GET | S |
| /auth/get_admin_strategy_list/ | GET | S |
| /auth/get_admin_user_list/ | GET | S |
| /auth/get_margin_calculator/ | GET | B |
| /auth/get_margin_calculator1/ | GET | B |
| /auth/get_referal_link/ | GET | B |
| /auth/get_strategy_data/ | GET | B |
| /auth/get_tutorial/ | GET | B |
| /auth/get_user_positions/ | GET | B |
| /auth/get_user_pnl/ | GET | B |
| /auth/highlow-strategies/ | GET, POST | S |
| /auth/highlow-strategies/<id>/ | GET, PUT, PATCH, DELETE | S |
| /auth/highlow-strategies-limited/ | POST | B |
| /auth/highlow-strategies1/ | GET, POST | B |
| /auth/highlow-strategies1/<id>/ | GET, PUT, PATCH, DELETE | B |
| /auth/internal-signal/ | POST | B |
| /auth/latency/ | GET, POST | S |
| /auth/latency/<id>/ | GET, PUT, PATCH, DELETE | S |
| /auth/login/ | POST | N |
| /auth/notifications/ | GET | B |
| /auth/orders/ | GET | B |
| /auth/orders/paper/ | GET | B |
| /auth/pl-report/pdf/ | GET | B |
| /auth/payment/balance/ | GET | B |
| /auth/payment/create-order/ | POST | B |
| /auth/payment/invoice/<invoice_id>/ | GET | B |
| /auth/payment/ledger/ | GET | B |
| /auth/payment/test-email/ | POST | B |
| /auth/payment/verify/ | POST | B |
| /auth/payment/webhook/ | POST | Server |
| /auth/profile/ | GET, PATCH | B |
| /auth/remove_user_to_strategy/ | POST | B |
| /auth/send-otp/ | POST | N |
| /auth/session/ | GET | B |
| /auth/setSignal/ | POST | B |
| /auth/signal/ | POST | B |
| /auth/signal-list/ | GET | B |
| /auth/signup/ | POST | N |
| /auth/strategies/ | GET | B |
| /auth/strategies/deployed/ | GET | B |
| /auth/strategy/ai/generate-strategy/ | POST | B |
| /auth/strategy/ai/generate-strategy/status/ | GET | B |
| /auth/strategy/ai/health/ | GET | B |
| /auth/strategy/backtest/check-open-position/ | GET | B |
| /auth/strategy/backtest/deploy/ | POST | B |
| /auth/strategy/backtest/detail/ | GET | B |
| /auth/strategy/backtest/detail/chart/ | GET | B |
| /auth/strategy/backtest/detail/report/ | GET | B |
| /auth/strategy/backtest/edit/ | POST | B |
| /auth/strategy/backtest/indicators/ | POST | B |
| /auth/strategy/backtest/list/ | GET | B |
| /auth/strategy/backtest/pine-code/ | GET | B |
| /auth/strategy/backtest/report/<backtest_id>/ | GET | B |
| /auth/strategy/backtest/result/ | GET | B |
| /auth/strategy/backtest/share/ | GET, POST, DELETE | B |
| /auth/strategy/backtest/trade-mode/ | POST | B |
| /auth/strategy/backtest/validate/ | POST | B |
| /auth/strategy/copilot/backtest/ | POST | B |
| /auth/strategy/copilot/chat/ | POST | B |
| /auth/strategy/copilot/code-conversion/ | POST | B |
| /auth/strategy/copilot/convert/ | POST | B |
| /auth/strategy/copilot/convert-test/ | POST | B |
| /auth/strategy/copilot/fetch-conversions/ | GET | B |
| /auth/strategy/copilot/history/ | GET | B |
| /auth/strategy/copilot/prepare-backtest/ | POST | B |
| /auth/strategy/copilot/save-strategy/ | POST | B |
| /auth/strategy/copilot/smart-convert/ | POST | B |
| /auth/strategy/copilot/smart-convert-test/ | POST | B |
| /auth/strategy/copilot/stream/ | POST | B |
| /auth/strategy/dashboard/ | GET | B |
| /auth/strategy/deep-think-optimize/ | POST | B |
| /auth/strategy/deep-think-optimize-v2/ | POST | B |
| /auth/strategy/deep-think-optimize-v2/status/ | GET | B |
| /auth/strategy/deep-think-optimize-v2/sync/ | POST | B |
| /auth/strategy/delete/ | POST | B |
| /auth/strategy/improve/ | POST | B |
| /auth/strategy/improve/quote/ | POST | B |
| /auth/strategy/rerun-backtest/ | POST | B |
| /auth/strategy/search-user/ | GET | B |
| /auth/strategy/sync-deployed/ | POST | B |
| /auth/strategy/check-deployment-sync/ | GET | B |
| /auth/strategy/update-name/ | POST | B |
| /auth/strategy/users/<strategy_id>/detailed/ | GET | B |
| /auth/system/api-latency-history/ | GET | S |
| /auth/system/backtest-queue/ | GET | S |
| /auth/system/celery-workers/ | GET | S |
| /auth/system/cron-jobs/ | GET | S |
| /auth/system/cron-jobs/<job_name>/run/ | POST | S |
| /auth/system/cron-jobs/<job_name>/toggle/ | POST | S |
| /auth/system/error-logs/<error_id>/ | GET | S |
| /auth/system/error-logs/<error_id>/resolve/ | POST | S |
| /auth/system/errors/ | GET | S |
| /auth/system/performance/ | GET | S |
| /auth/system/redis-detailed/ | GET | S |
| /auth/system/registered-endpoints/ | GET | S |
| /auth/system/strategy-engine/ | GET | S |
| /auth/system/top-endpoints/ | GET | S |
| /auth/today_dashboardcount/ | GET | S |
| /auth/trades/ | GET | B |
| /auth/trades/paper/ | GET | B |
| /auth/tutorial-ai/ | GET | B |
| /auth/tutorial-ai/generate/ | POST | B |
| /auth/tutorial-ai/generate-all/ | POST | B |
| /auth/tutorials/ | GET | B |
| /auth/tutorials/<pk>/ | GET | B |
| /auth/user/ | GET, PATCH | B |
| /auth/user/add_strategy/ | POST | B |
| /auth/user/admin_user_strategy/ | GET | B |
| /auth/user/open_position/ | POST | B |
| /auth/user/positions/paper/ | GET | B |
| /auth/user/user_strategy/ | GET | B |
| /auth/user/strategies/ | GET | B |
| /auth/user/strategies/deploy/ | POST | B |
| /auth/user/strategies/undeploy/ | POST | B |
| /auth/user/auto-close-position/ | POST | B |
| /auth/userNotifications/ | GET | B |
| /auth/userOrderDetails/ | GET | B |
| /auth/user_strategy_set/ | POST | B |
| /auth/users/phone/<phone>/ | GET | S |
| /auth/watchlist/ | GET | B |
| /payment/webhook/razorpay/ | POST | Public |
| /strategy/pnl/ | GET | B |
| /strategy/templates/ | GET | B |
| /strategy/user/ | GET | B |
| /strategy/user-strategy/ | GET | B |

---

**End of API Documentation.** This file lists every endpoint from Crypto_Arth_Backend (digno/config/urls.py and router). Use with the Postman collection for ready-to-run requests.
