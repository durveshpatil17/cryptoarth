import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/core/network/api_client.dart';
import 'package:cryptoarth/core/network/api_endpoints.dart';

final tutorialServiceProvider = Provider((ref) => TutorialService());

class TutorialService {
  final ApiClient _apiClient = ApiClient();

  Future<List<dynamic>> fetchTutorials() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.tutorialsList);
      return ApiClient.extractList(response.data);
    } catch (e) {
      throw Exception('Failed to fetch tutorials: $e');
    }
  }

  Future<Map<String, dynamic>> fetchTutorialDetail(int id) async {
    try {
      final Response response = await _apiClient.get("${ApiEndpoints.tutorialsList}$id/");
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to fetch tutorial detail: $e');
    }
  }

  Future<Map<String, dynamic>> fetchAiTutorials() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.tutorialAiFetch);
      return ApiClient.extractMap(response.data);
    } catch (e) {
      throw Exception('Failed to fetch AI tutorials: $e');
    }
  }

  Future<void> generateAiTutorial(Map<String, dynamic> data) async {
    try {
      await _apiClient.post(ApiEndpoints.tutorialAiGenerate, data);
    } catch (e) {
      throw Exception('Failed to generate AI tutorial: $e');
    }
  }

  Future<void> generateAllAiTutorials() async {
    try {
      await _apiClient.post(ApiEndpoints.tutorialAiGenerateAll, {});
    } catch (e) {
      throw Exception('Failed to generate all AI tutorials: $e');
    }
  }
}
