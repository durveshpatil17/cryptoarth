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
  static const String openPosition = "/auth/user/open_position/";
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
  static const String backtestDeploy = "/auth/strategy/backtest/deploy/";

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
  static const String brokerConnect1 = "/auth/broker/connect1/";
  static const String diagnostic = "/auth/diagnostic/";
  static const String connectCoinDcx = "/auth/connect/coindcx/";
  static const String brokerBalance = "/auth/broker/balance/";

  static const String paymentBalance = "/auth/payment/balance/";
  static const String paymentLedger = "/auth/payment/ledger/";
  static const String paymentCreateOrder = "/auth/payment/create-order/";
  static const String paymentVerify = "/auth/payment/verify/";

  static const String notifications = "/auth/notifications/";
  static const String referralLink = "/auth/get_referal_link/";

  // Execution History Actions
  static const String backtestEdit = "/auth/strategy/backtest/edit/";
  static const String backtestPine = "/auth/strategy/backtest/pine-code/";
  static const String backtestShare = "/auth/strategy/backtest/share/";
  static const String strategySearchUser = "/auth/strategy/search-user/";
  static const String strategyImprove = "/auth/strategy/improve/";
  static const String strategyDeepThink = "/auth/strategy/deep-think-optimize-v2/";
  static const String strategyDelete = "/auth/strategy/delete/";
  static const String backtestDelete = "/auth/strategy/backtest/delete/";
  
  // Backtest / Copilot
  static const String copilotChat = "/auth/strategy/copilot/chat/";
  static const String copilotHistory = "/auth/strategy/copilot/history/";
  static const String copilotSave = "/auth/strategy/copilot/save-strategy/";

  // Missing or Newly identified endpoints
  static const String backtestRerun = "/auth/strategy/rerun-backtest/";
  static const String backtestReportPdf = "/auth/strategy/backtest/report/"; // Needs backtest_id
  static const String backtestIndicators = "/auth/strategy/backtest/indicators/";
  static const String backtestValidate = "/auth/strategy/backtest/validate/";
  static const String backtestTradeMode = "/auth/strategy/backtest/trade-mode/";
  static const String deepThinkStatus = "/auth/strategy/deep-think-optimize-v2/status/";
  static const String deepThinkSync = "/auth/strategy/deep-think-optimize-v2/sync/";

  // Signals
  static const String signalProcess = "/auth/signal/";
  static const String signalCopy = "/auth/copy-signal/";
  static const String signalSet = "/auth/setSignal/";
  static const String signalDelete = "/auth/deleteSignal/";
  static const String signalEditActive = "/auth/editActiveSignal/";
  static const String signalEditPending = "/auth/edidPendingSignal/";
  static const String signalClose = "/auth/closeSignal/";
  static const String signalList = "/auth/signal-list/";
  static const String copyStrategyShow = "/auth/copystrategyshow/";

  // Tutorials
  static const String tutorialsList = "/auth/tutorials/";
  static const String tutorialAiFetch = "/auth/tutorial-ai/";
  static const String tutorialAiGenerate = "/auth/tutorial-ai/generate/";
  static const String tutorialAiGenerateAll = "/auth/tutorial-ai/generate-all/";
  static const String getTutorial = "/auth/get_tutorial/";

  // Additional Strategy/Copilot
  static const String strategyImproveQuote = "/auth/strategy/improve/quote/";
  static const String strategyDeepThinkV1 = "/auth/strategy/deep-think-optimize/";
  static const String copilotStream = "/auth/strategy/copilot/stream/";
  static const String copilotConversions = "/auth/strategy/copilot/fetch-conversions/";
  static const String codeConversion = "/auth/strategy/copilot/code-conversion/";
  static const String checkOpenPosition = "/auth/strategy/backtest/check-open-position/";

  // Payments / Admin / System
  static const String invoiceDownload = "/auth/payment/invoice/"; // Needs ID
  static const String adminStrategyList = "/auth/get_admin_strategy_list/";
  static const String systemPerformance = "/auth/system/performance/";
}
