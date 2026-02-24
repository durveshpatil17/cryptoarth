import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/core/network/api_client.dart';
import 'package:cryptoarth/core/network/api_endpoints.dart';

final copilotServiceProvider = Provider((ref) => CopilotService());

class CopilotService {
  final ApiClient _apiClient = ApiClient();

  Future<dynamic> fetchChatHistory({String? sessionId}) async {
    try {
      String url = ApiEndpoints.copilotHistory;
      if (sessionId != null) {
        url = "$url?session_id=$sessionId";
      }
      final Response response = await _apiClient.get(url);
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch chat history: $e');
    }
  }

  Future<Map<String, dynamic>> sendChatMessage({
    required List<Map<String, dynamic>> messages,
    String? strategyCode,
    String? id,
    String? selectedChatModel,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "messages": messages,
      };
      if (strategyCode != null) body["strategy_code"] = strategyCode;
      if (id != null) body["id"] = id;
      if (selectedChatModel != null) body["selectedChatModel"] = selectedChatModel;

      print("📤 COPILOT CHAT REQUEST BODY: $body");

      final Response response = await _apiClient.post(ApiEndpoints.copilotChat, body);
      
      final Map<String, dynamic> data = ApiClient.extractMap(response.data);
      print("✅ API RESPONSE [${response.statusCode}] → /chat/");
      print("📥 COPILOT CHAT RESPONSE: $data");
      
      return data;
    } catch (e) {
      print("🚨 COPILOT CHAT ERROR: $e");
      throw Exception('Failed to send message: $e');
    }
  }

  Future<String> triggerStream({
    required String id,
    required String requestId,
    required List<Map<String, dynamic>> messages,
    String selectedChatModel = "claude-sonnet-4-5-20250929",
  }) async {
    int attempts = 0;
    const int maxAttempts = 2;

    while (attempts < maxAttempts) {
      attempts++;
      bool isDone = false;
      String currentAttemptMessage = "";

      try {
        final body = {
          "id": id,
          "messages": messages,
          "selectedChatModel": selectedChatModel,
        };
        
        print("📤 TRIGGER STREAM [Attempt $attempts/$maxAttempts]: $body");

        final response = await _apiClient.post(
          ApiEndpoints.copilotStream, 
          body,
          options: Options(
            responseType: ResponseType.stream,
            validateStatus: (status) => true,
            sendTimeout: const Duration(minutes: 2),
            receiveTimeout: const Duration(minutes: 2),
            headers: {
              "Accept": "text/event-stream",
              "Content-Type": "application/json",
              "x-request-id": requestId,
            },
          ),
        );

        if (response.statusCode != 200) {
          throw Exception("Stream failed with status: ${response.statusCode}");
        }

        final responseBody = response.data as ResponseBody;
        final stream = responseBody.stream
            .cast<List<int>>()
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        print("📡 SSE STREAM CONNECTED [Attempt $attempts]");

        await for (final line in stream) {
          if (!line.startsWith("data: ")) continue;

          final jsonStr = line.replaceFirst("data: ", "").trim();
          if (jsonStr.isEmpty) continue;

          try {
            final event = jsonDecode(jsonStr);
            final type = event["type"];

            if (type == "error") {
              final String errorMsg = event["message"]?.toString() ?? "";
              print("⚠️ Backend error event received: $errorMsg");
              
              if (errorMsg.contains("Minimum balance") || 
                  errorMsg.contains("required") || 
                  errorMsg.contains("Please add credits")) {
                print("🚨 INSUFFICIENT BALANCE DETECTED. Stopping stream.");
                throw Exception("INSUFFICIENT_BALANCE");
              }
              print("ℹ️ Continuing to wait for 'done' per Web contract...");
              continue; // 🎯 DO NOT break
            }
            if (type == "done") {
              print("✅ STREAM COMPLETE (type: done) [Attempt $attempts]");
              isDone = true;
              break; // 🎯 ONLY break here
            }

            if (type == "delta") {
              currentAttemptMessage += event["content"] ?? "";
            }
            
            // Handle other intermediate events (balance_update, etc.)
            if (type == "balance_update") {
              print("💰 Received balance_update event");
            }
          } catch (e) {
            if (e.toString().contains("INSUFFICIENT_BALANCE")) rethrow;
            print("⚠️ FAILED TO DECODE SSE LINE: $line | Error: $e");
          }
        }

        if (isDone) {
          return currentAttemptMessage;
        } else {
          print("⚠️ Stream closed without 'done' signal [Attempt $attempts]");
          if (attempts >= maxAttempts) {
            print("🚨 Max retries reached. Returning accumulated message.");
            return currentAttemptMessage;
          }
          print("🔄 Retrying stream once more...");
        }
      } catch (e) {
        if (e.toString().contains("INSUFFICIENT_BALANCE")) rethrow;
        print("🚨 TRIGGER STREAM ERROR [Attempt $attempts]: $e");
        if (attempts >= maxAttempts) {
          throw Exception('Connection error during AI generation after $attempts attempts: $e');
        }
        print("🔄 Retrying stream once more...");
      }
    }
    return ""; // Should not reach here
  }

  Future<List<dynamic>> fetchConversions() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.copilotConversions);
      return ApiClient.extractList(response.data);
    } catch (e) {
      throw Exception('Failed to fetch conversions: $e');
    }
  }
}
