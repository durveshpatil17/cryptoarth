class ApiEndpoints {
  static const String baseUrl = "https://trade-api.cryptoarth.in";

  static const String sendOtp = "/auth/send-otp/";
  static const String login = "/auth/login/";
  static const String signup = "/auth/signup/";
  static const String consumeOtp = "/auth/consume-otp/";
  static const String session = "/auth/session/";
  static const String profile = "/auth/profile/";
  static const String checkPhone = "/auth/check-phone/";

  static const String userPositions = "/auth/get_user_positions/";
  static const String userPositionsPaper = "/auth/user/positions/paper/";
  static const String userPnL = "/auth/get_user_pnl/";
  static const String pnlReportPdf = "/auth/pl-report/pdf/";
  static const String watchlist = "/auth/watchlist/";

  static const String orders = "/auth/orders/";
  static const String ordersPaper = "/auth/orders/paper/";
  static const String tradesLive = "/auth/trades/";
  static const String tradesPaper = "/auth/trades/paper/";
  static const String userOrderDetails = "/auth/userOrderDetails/";

  static const String userStrategies = "/auth/user/strategies/";
  static const String strategyDashboard = "/auth/strategy/dashboard/";
  static const String deployedStrategies = "/auth/strategies/deployed/";
  static const String deployStrategy = "/auth/user/strategies/deploy/";
  static const String undeployStrategy = "/auth/user/strategies/undeploy/";

  static const String backtestList = "/auth/strategy/backtest/list/";
  static const String backtestDetail = "/auth/strategy/backtest/detail/";
  static const String backtestResult = "/auth/strategy/backtest/result/";
  static const String backtestPrepare = "/auth/strategy/copilot/prepare-backtest/";
  static const String backtestRun = "/auth/strategy/copilot/backtest/";
  static const String backtestChart = "/auth/strategy/backtest/detail/chart/";
  static const String backtestReport = "/auth/strategy/backtest/detail/report/";
  static const String backtestCandles = "/auth/backtest/candles/";
  static const String backtestSymbols = "/auth/backtest-symbols/";

  static const String brokerConnect = "/auth/broker/connect/";
  static const String diagnostic = "/auth/diagnostic/";
  static const String connectCoinDcx = "/auth/connect/coindcx/";
  static const String brokerBalance = "/auth/broker/balance/";

  static const String paymentBalance = "/auth/payment/balance/";
  static const String paymentLedger = "/auth/payment/ledger/";
  static const String paymentCreateOrder = "/auth/payment/create-order/";
  static const String paymentVerify = "/auth/payment/verify/";

  static const String notifications = "/auth/notifications/";
  static const String referralLink = "/auth/get_referal_link/";
}
