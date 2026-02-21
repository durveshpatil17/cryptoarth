import 'package:dio/dio.dart';
import 'package:cryptoarth/core/network/api_client.dart';
import 'package:cryptoarth/core/network/api_endpoints.dart';
import 'package:cryptoarth/features/portfolio/models/position_model.dart';
import 'package:cryptoarth/features/portfolio/models/pnl_model.dart';

class PortfolioService {
  final ApiClient _apiClient = ApiClient();

  Future<List<PositionModel>> fetchUserPositions() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.userPositions);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = ApiClient.extractList(response.data);
        return data.map((json) => PositionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch user positions: $e');
    }
  }

  Future<PnLModel> fetchUserPnL() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.userPnL);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = ApiClient.extractMap(response.data);
        return PnLModel.fromJson(data);
      }
      throw Exception('Invalid PnL backend response');
    } catch (e) {
      throw Exception('Failed to fetch user PnL: $e');
    }
  }
}
