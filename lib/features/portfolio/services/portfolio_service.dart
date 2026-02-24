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

  Future<List<PositionModel>> fetchUserPaperPositions() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.userPositionsPaper);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = ApiClient.extractList(response.data);
        return data.map((json) => PositionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch user paper positions: $e');
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

  Future<String?> fetchPnlReportPdfUrl() async {
    // Generate full URL since it usually returns a download stream or link
    return "${ApiEndpoints.baseUrl}${ApiEndpoints.pnlReportPdf}";
  }

  Future<List<dynamic>> fetchUserWatchlist() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.watchlist);
      return ApiClient.extractList(response.data);
    } catch (e) {
      // Typically 403s happen here if user hasn't connected a broker or lacks permissions yet
      // To avoid crashing the entire UI with red errors we catch it and fallback nicely.
      if (e.toString().contains('403') || e.toString().contains('permission')) {
        return [];
      }
      return []; // Return empty list on error to keep UI clean instead of throw Exception
    }
  }

  Future<void> openPosition(Map<String, dynamic> data) async {
    try {
      await _apiClient.post(ApiEndpoints.openPosition, data);
    } catch (e) {
      throw Exception('Failed to open position: $e');
    }
  }
}
