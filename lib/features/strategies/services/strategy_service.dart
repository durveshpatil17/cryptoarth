import 'package:dio/dio.dart';
import 'package:cryptoarth/core/network/api_client.dart';
import 'package:cryptoarth/core/network/api_endpoints.dart';
import 'package:cryptoarth/features/strategies/models/strategy_model.dart';
import 'package:cryptoarth/features/strategies/models/deployed_strategy_model.dart';
import 'package:cryptoarth/features/strategies/models/backtest_model.dart';

class StrategyService {
  final ApiClient _apiClient = ApiClient();

  Future<List<StrategyModel>> fetchUserStrategies() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.userStrategies);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = ApiClient.extractList(response.data);
        return data.map((json) => StrategyModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch user strategies: $e');
    }
  }

  Future<List<StrategyModel>> fetchDashboardStrategies({bool lite = false, bool cards = false}) async {
    try {
      final queryParams = <String, String>{};
      if (lite) queryParams['lite'] = '1';
      if (cards) queryParams['cards'] = '1';
      
      final String uri = queryParams.isEmpty 
          ? ApiEndpoints.strategyDashboard 
          : "${ApiEndpoints.strategyDashboard}?${Uri(queryParameters: queryParams).query}";

      final Response response = await _apiClient.get(uri);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = ApiClient.extractList(response.data);
        return data.map((json) => StrategyModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch dashboard strategies: $e');
    }
  }

  Future<List<DeployedStrategyModel>> fetchDeployedStrategies() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.deployedStrategies);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = ApiClient.extractList(response.data);
        return data.map((json) => DeployedStrategyModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch deployed strategies: $e');
    }
  }

  Future<void> deployStrategy(String strategyId, int brokerId, {int? userId}) async {
    try {
      await _apiClient.post(ApiEndpoints.deployStrategy, {
        "strategyid": strategyId,
        "broker_id": brokerId,
        if (userId != null) "user_id": userId,
      });
    } catch (e) {
      throw Exception('Failed to deploy strategy: $e');
    }
  }

  Future<void> undeployStrategy(dynamic strategyId) async {
    try {
      await _apiClient.post(ApiEndpoints.undeployStrategy, {
        "strategyid": strategyId,
      });
    } catch (e) {
      throw Exception('Failed to undeploy strategy: $e');
    }
  }

  Future<List<BacktestModel>> fetchBacktestList() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.backtestList);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = ApiClient.extractList(response.data);
        return data.map((json) => BacktestModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch backtest list: $e');
    }
  }

  Future<BacktestModel> fetchBacktestDetail(String strategyCode) async {
    try {
      final Response response = await _apiClient.get(
        "${ApiEndpoints.backtestDetail}?strategy_code=$strategyCode"
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = ApiClient.extractMap(response.data);
        return BacktestModel.fromJson(data);
      }
      throw Exception('Invalid backtest detail response');
    } catch (e) {
      throw Exception('Failed to fetch backtest detail: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBacktestResult(String backtestId) async {
    try {
      final Response response = await _apiClient.get(
        "${ApiEndpoints.backtestResult}?backtest_id=$backtestId"
      );
      if (response.statusCode == 200 && response.data != null) {
        return ApiClient.extractMap(response.data);
      }
      throw Exception('Invalid backtest result response');
    } catch (e) {
      throw Exception('Failed to fetch backtest result: $e');
    }
  }

  Future<Map<String, dynamic>> prepareBacktest(Map<String, dynamic> data) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.backtestPrepare, data);
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to prepare backtest: $e');
    }
  }

  Future<Map<String, dynamic>> runBacktest(Map<String, dynamic> data) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.backtestRun, data);
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to run backtest: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBacktestChart(String backtestId) async {
    try {
      final Response response = await _apiClient.get("${ApiEndpoints.backtestChart}?backtest_id=$backtestId");
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to fetch backtest chart: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBacktestReport(String backtestId) async {
    try {
      final Response response = await _apiClient.get("${ApiEndpoints.backtestReport}?backtest_id=$backtestId");
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to fetch backtest report: $e');
    }
  }

  Future<List<dynamic>> fetchBacktestCandles(Map<String, dynamic> queryParams) async {
    try {
      // Simplistic query building string representation manually or using Dio
      // We will let Dio handle Map to query conversion
      final Response response = await _apiClient.get("${ApiEndpoints.backtestCandles}?${Uri(queryParameters: queryParams).query}");
      return ApiClient.extractList(response.data);
    } catch (e) {
      throw Exception('Failed to fetch backtest candles: $e');
    }
  }

  Future<List<dynamic>> fetchBacktestSymbols() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.backtestSymbols);
      return ApiClient.extractList(response.data);
    } catch (e) {
      throw Exception('Failed to fetch backtest symbols: $e');
    }
  }

  Future<Map<String, dynamic>?> checkUserPhone(String phone) async {
    try {
      final Response response = await _apiClient.post(
        ApiEndpoints.checkPhone, 
        {"phone": phone},
      );
      if (response.statusCode == 200) {
        final data = ApiClient.extractMap(response.data);
        if (data['exists'] == true) {
          return data;
        }
        return null; // Exists is false
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      return null;
    }
  }

  Future<void> updateStrategyAccess(String strategyCode, String accessType, List<String> sharedWith) async {
    try {
      // Mocking the update process since PATCH on detail endpoint returns 405 Method Not Allowed
      // TODO: Replace with actual backend API call once the backend implements strategy update
      await Future.delayed(const Duration(milliseconds: 500));
      print("MOCK API: Strategy $strategyCode access updated to $accessType");
      if (accessType == "Shared") {
        print("MOCK API: Shared with $sharedWith");
      }
    } catch (e) {
      throw Exception('Failed to update strategy access: $e');
    }
  }
}
