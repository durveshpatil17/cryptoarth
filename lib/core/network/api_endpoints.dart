class ApiEndpoints {

  // CHANGE THIS LATER TO YOUR REAL SERVER
  static const String baseUrl = "http://localhost:8000/api";

  // AUTH
  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String logout = "/auth/logout";

  // USER
  static const String profile = "/user/profile";

  // STRATEGY
  static const String generateStrategy = "/strategy/generate";
  static const String backtest = "/strategy/backtest";

  // PORTFOLIO
  static const String portfolio = "/portfolio";

  // MARKETPLACE
  static const String marketplace = "/marketplace";

}
