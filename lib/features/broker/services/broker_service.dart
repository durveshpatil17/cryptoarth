import 'package:dio/dio.dart';
import 'package:cryptoarth/core/network/api_client.dart';
import 'package:cryptoarth/core/network/api_endpoints.dart';
import 'package:cryptoarth/features/broker/models/broker_balance_model.dart';
import 'package:cryptoarth/features/broker/models/broker_model.dart';

class BrokerService {
  final ApiClient _apiClient = ApiClient();

  Future<void> connectBroker({
    required String apiKey,
    required String apiSecret,
    required String broker,
    required String name,
    bool disableIp = false,
  }) async {
    try {
      await _apiClient.post(ApiEndpoints.brokerConnect1, {
        "api_key": apiKey,
        "api_secret": apiSecret,
        "broker": broker,
        "datetime": DateTime.now().toUtc().toIso8601String(),
        "disable_ip": disableIp,
        "name": name,
      });
    } catch (e) {
      throw Exception('Failed to connect $broker: $e');
    }
  }

  Future<bool> testBrokerConnection(String apiKey, String apiSecret, String broker) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.diagnostic, {
        "api_key": apiKey,
        "api_secret": apiSecret,
        "broker": broker,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false; // Connection test failed
    }
  }

  Future<BrokerBalanceModel> fetchBrokerBalance() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.brokerBalance);
      if (response.statusCode == 200 && response.data != null) {
         return BrokerBalanceModel.fromJson(response.data);
      }
      throw Exception('Invalid backend response');
    } catch (e) {
      throw Exception('Failed to fetch broker balance: $e');
    }
  }
}
