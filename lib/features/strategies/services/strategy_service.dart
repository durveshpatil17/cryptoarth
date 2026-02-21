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

  Future<List<StrategyModel>> fetchDashboardStrategies() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.strategyDashboard);
      
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

  Future<void> deployStrategy(String strategyId, int brokerId) async {
    try {
      await _apiClient.post(ApiEndpoints.deployStrategy, {
        "strategy_id": strategyId,
        "broker_id": brokerId,
      });
    } catch (e) {
      throw Exception('Failed to deploy strategy: $e');
    }
  }

  Future<void> undeployStrategy(String strategyId) async {
    try {
      await _apiClient.post(ApiEndpoints.undeployStrategy, {
        "strategy_id": strategyId,
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
}
