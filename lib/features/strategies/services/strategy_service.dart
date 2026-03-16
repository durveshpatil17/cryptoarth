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

  Future<Map<String, dynamic>> deployStrategy(String strategyCode) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.backtestDeploy, {
        "strategy_code": strategyCode,
        "is_active": 1,
      });
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to deploy strategy: $e');
    }
  }

  Future<void> deployCopilotStrategy(dynamic strategyId, String mode, {int? userId}) async {
    try {
      final idToPass = strategyId is String ? (int.tryParse(strategyId) ?? strategyId) : strategyId;
      await _apiClient.post(ApiEndpoints.deployStrategy, {
        "strategyid": idToPass,
        "mode": mode,
        if (userId != null) "user_id": userId,
      });
    } catch (e) {
      throw Exception('Failed to deploy strategy: $e');
    }
  }

  Future<Map<String, dynamic>> undeployStrategy(String strategyCode) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.backtestDeploy, {
        "strategy_code": strategyCode,
        "is_active": 0,
      });
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to undeploy strategy: $e');
    }
  }

  Future<List<BacktestModel>> fetchBacktestList({bool lite = false, String? type}) async {
    try {
      final queryParams = <String, String>{};
      if (lite) queryParams['lite'] = '1';
      if (type != null) queryParams['type'] = type;

      final String uri = queryParams.isEmpty 
          ? ApiEndpoints.backtestList 
          : "${ApiEndpoints.backtestList}?${Uri(queryParameters: queryParams).query}";

      final Response response = await _apiClient.get(uri);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = ApiClient.extractList(response.data);
        return data.map((json) => BacktestModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch backtest list: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBacktestDetailRaw(String strategyCode) async {
    try {
      final Response response = await _apiClient.get(
        "${ApiEndpoints.backtestDetail}?strategy_code=$strategyCode"
      );
      final data = ApiClient.extractMap(response.data);
      return data['strategy'] ?? data;
    } catch (e) {
      throw Exception('Failed to fetch backtest detail: $e');
    }
  }

  Future<BacktestModel> fetchBacktestDetail(String strategyCode) async {
     final data = await fetchBacktestDetailRaw(strategyCode);
     return BacktestModel.fromJson(data);
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

  Future<Map<String, dynamic>> createStrategy(Map<String, dynamic> data) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.copilotSave, data);
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to create strategy: $e');
    }
  }

  Future<Map<String, dynamic>> convertCode(Map<String, dynamic> data) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.codeConversion, data);
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to convert code: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBacktestChart(String strategyCode) async {
    try {
      final Response response = await _apiClient.get("${ApiEndpoints.backtestChart}?strategy_code=$strategyCode");
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to fetch backtest chart: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBacktestReport(String strategyCode) async {
    try {
      final Response response = await _apiClient.get("${ApiEndpoints.backtestReport}?strategy_code=$strategyCode");
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to fetch backtest report: $e');
    }
  }

  Future<List<dynamic>> fetchBacktestCandles({
    required String symbol,
    required String timeframe,
    required int start,
    required int end,
    int limit = 0,
    int maxOut = 20000,
  }) async {
    try {
      final queryParams = {
        'symbol': symbol,
        'timeframe': timeframe,
        'start': start.toString(),
        'end': end.toString(),
        'limit': limit.toString(),
        'max_out': maxOut.toString(),
      };
      
      final Response response = await _apiClient.get(
        ApiEndpoints.backtestCandles,
        queryParameters: queryParams,
      );
      
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
      final Response response = await _apiClient.get(
        "${ApiEndpoints.strategySearchUser}?phone=$phone",
      );
      if (response.statusCode == 200) {
        final data = ApiClient.extractMap(response.data);
        // ApiClient.extractMap auto-dives into 'user' if it exists.
        // So we check if the extracted map contains user identifier keys or the exists flag.
        if (data.isNotEmpty && (data.containsKey('id') || data.containsKey('user_id') || data['exists'] == true)) {
          return data;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateStrategyAccess(String strategyCode, String accessType, List<String> sharedWith) async {
    try {
      // Use the new edit endpoint for access_type updates
      await _apiClient.post(ApiEndpoints.backtestEdit, {
        "strategy_code": strategyCode,
        "access_type": accessType,
      });
      
      // If sharedWith is not empty, we might need to call the share endpoint for each user
      // For now, let's assume the edit endpoint handles the basic access_type
    } catch (e) {
      throw Exception('Failed to update strategy access: $e');
    }
  }

  Future<void> editStrategy(String strategyCode, Map<String, dynamic> updates) async {
    try {
      await _apiClient.post(ApiEndpoints.backtestEdit, {
        "strategy_code": strategyCode,
        ...updates,
      });
    } catch (e) {
      throw Exception('Failed to edit strategy: $e');
    }
  }

  Future<void> deleteStrategy(String strategyCode) async {
    try {
      await _apiClient.post(ApiEndpoints.strategyDelete, {
        "strategy_code": strategyCode,
      });
    } catch (e) {
      throw Exception('Failed to delete strategy: $e');
    }
  }

  Future<void> shareStrategy(String strategyCode, dynamic userId) async {
    try {
      await _apiClient.post(ApiEndpoints.backtestShare, {
        "strategy_code": strategyCode,
        "user_id": userId,
      });
    } catch (e) {
      throw Exception('Failed to share strategy: $e');
    }
  }

  Future<void> removeShareAccess(String strategyCode, dynamic userId) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.backtestShare,
        data: {
          "strategy_code": strategyCode,
          "user_id": userId,
        },
      );
    } catch (e) {
      throw Exception('Failed to remove share access: $e');
    }
  }

  Future<List<dynamic>> fetchShareList(String strategyCode) async {
    try {
      final Response response = await _apiClient.get("${ApiEndpoints.backtestShare}?strategy_code=$strategyCode");
      final data = ApiClient.extractMap(response.data);
      if (data.containsKey('access_users') && data['access_users'] is List) {
        return data['access_users'];
      }
      return ApiClient.extractList(response.data);
    } catch (e) {
      throw Exception('Failed to fetch share list: $e');
    }
  }

  Future<void> improveStrategy(String strategyCode) async {
    try {
      await _apiClient.post(ApiEndpoints.strategyImprove, {
        "strategy_code": strategyCode,
      });
    } catch (e) {
      throw Exception('Failed to improve strategy: $e');
    }
  }

  Future<Map<String, dynamic>> deepThinkOptimizeV2(String strategyCode) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.strategyDeepThink, {
        "strategy_code": strategyCode,
      });
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to start deep think optimization: $e');
    }
  }

  Future<String> fetchPineCode(String strategyCode) async {
    try {
      final Response response = await _apiClient.get("${ApiEndpoints.backtestPine}?strategy_code=$strategyCode");
      final data = ApiClient.extractMap(response.data);
      return data['code'] ?? data['pine_code'] ?? data['pine_script'] ?? '';
    } catch (e) {
      throw Exception('Failed to fetch pine code: $e');
    }
  }

  Future<Map<String, dynamic>> rerunBacktest(String strategyCode) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.backtestRerun, {
        "strategy_code": strategyCode,
      });
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to rerun backtest: $e');
    }
  }

  Future<String> fetchBacktestReportPdf(String backtestId) async {
    try {
      return "${ApiEndpoints.baseUrl}${ApiEndpoints.backtestReportPdf}$backtestId/";
    } catch (e) {
      throw Exception('Failed to get backtest report PDF URL: $e');
    }
  }

  Future<void> updateBacktestIndicators(String strategyCode, List<Map<String, dynamic>> indicators) async {
    try {
      await _apiClient.post(ApiEndpoints.backtestIndicators, {
        "strategy_code": strategyCode,
        "indicators": indicators,
      });
    } catch (e) {
      throw Exception('Failed to update backtest indicators: $e');
    }
  }

  Future<Map<String, dynamic>> validateBacktest(String strategyCode) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.backtestValidate, {
        "strategy_code": strategyCode,
      });
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to validate backtest: $e');
    }
  }

  Future<void> setBacktestTradeMode(String strategyCode, int tradeMode) async {
    try {
      await _apiClient.post(ApiEndpoints.backtestTradeMode, {
        "strategy_code": strategyCode,
        "trade_mode": tradeMode,
      });
    } catch (e) {
      throw Exception('Failed to set trade mode: $e');
    }
  }

  Future<Map<String, dynamic>> fetchDeepThinkStatus() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.deepThinkStatus);
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to fetch deep think status: $e');
    }
  }

  Future<void> syncDeepThink() async {
    try {
      await _apiClient.post(ApiEndpoints.deepThinkSync, {});
    } catch (e) {
      throw Exception('Failed to sync deep think: $e');
    }
  }

  Future<Map<String, dynamic>> improveStrategyQuote(String strategyCode) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.strategyImproveQuote, {
        "strategy_code": strategyCode,
      });
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to fetch improvement quote: $e');
    }
  }

  Future<Map<String, dynamic>> deepThinkOptimizeV1(String strategyCode) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.strategyDeepThinkV1, {
        "strategy_code": strategyCode,
      });
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to start deep think v1: $e');
    }
  }

  Future<Map<String, dynamic>> checkOpenPosition(String strategyCode) async {
    try {
      final Response response = await _apiClient.get("${ApiEndpoints.checkOpenPosition}?strategy_code=$strategyCode");
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to check open position: $e');
    }
  }

  Future<void> deleteBacktest(String backtestId) async {
    try {
      await _apiClient.post(ApiEndpoints.backtestDelete, {
        "backtest_id": backtestId,
      });
    } catch (e) {
      throw Exception('Failed to delete backtest: $e');
    }
  }
}
