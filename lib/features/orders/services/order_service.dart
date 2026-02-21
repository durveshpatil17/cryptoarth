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
}
