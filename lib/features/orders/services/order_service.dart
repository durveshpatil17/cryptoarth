import 'package:dio/dio.dart';
import 'package:cryptoarth/core/network/api_client.dart';
import 'package:cryptoarth/core/network/api_endpoints.dart';
import 'package:cryptoarth/features/orders/models/order_model.dart';

class OrderService {
  final ApiClient _apiClient = ApiClient();

  Future<List<OrderModel>> fetchOrders() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.orders);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = ApiClient.extractList(response.data);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<List<OrderModel>> fetchPaperOrders() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.ordersPaper);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = ApiClient.extractList(response.data);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch paper orders: $e');
    }
  }

  Future<List<OrderModel>> fetchTrades() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.tradesLive);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = ApiClient.extractList(response.data);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch trades: $e');
    }
  }

  Future<List<OrderModel>> fetchPaperTrades() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.tradesPaper);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = ApiClient.extractList(response.data);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch paper trades: $e');
    }
  }

  Future<Map<String, dynamic>> fetchUserOrderDetails(String orderId) async {
    try {
      final Response response = await _apiClient.get("${ApiEndpoints.userOrderDetails}?order_id=$orderId");
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to fetch user order details: $e');
    }
  }
}
