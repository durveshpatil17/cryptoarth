import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/core/network/api_client.dart';
import 'package:cryptoarth/core/network/api_endpoints.dart';

final signalServiceProvider = Provider((ref) => SignalService());

class SignalService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> fetchSignals() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.signalList);
      return ApiClient.extractList(response.data);
    } catch (e) {
      throw Exception('Failed to fetch signals: $e');
    }
  }

  Future<void> processSignal(Map<String, dynamic> data) async {
    try {
      await _apiClient.post(ApiEndpoints.signalProcess, data);
    } catch (e) {
      throw Exception('Failed to process signal: $e');
    }
  }

  Future<void> setSignal(Map<String, dynamic> data) async {
    try {
      await _apiClient.post(ApiEndpoints.signalSet, data);
    } catch (e) {
      throw Exception('Failed to set signal: $e');
    }
  }

  Future<void> copySignal(Map<String, dynamic> data) async {
    try {
      await _apiClient.post(ApiEndpoints.signalCopy, data);
    } catch (e) {
      throw Exception('Failed to copy signal: $e');
    }
  }

  Future<void> deleteSignal(int signalId) async {
    try {
      await _apiClient.post(ApiEndpoints.signalDelete, {"id": signalId});
    } catch (e) {
      throw Exception('Failed to delete signal: $e');
    }
  }

  Future<void> closeSignal(int signalId) async {
    try {
      await _apiClient.post(ApiEndpoints.signalClose, {"id": signalId});
    } catch (e) {
      throw Exception('Failed to close signal: $e');
    }
  }

  Future<List<dynamic>> fetchCopyStrategies() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.copyStrategyShow);
      return ApiClient.extractList(response.data);
    } catch (e) {
      throw Exception('Failed to fetch copy strategies: $e');
    }
  }
}
