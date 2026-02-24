import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/services/copilot_service.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';
import 'package:cryptoarth/features/strategies/models/chat_message_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:convert';

final chatHistoryProvider = FutureProvider<List<dynamic>>((ref) async {
  final service = ref.read(copilotServiceProvider);
  final response = await service.fetchChatHistory();
  
  if (response is Map && response['messages'] is List) {
    return response['messages'] as List<dynamic>;
  } else if (response is List) {
    return response;
  }
  return [];
});

class CopilotNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  String? _sessionId;
  final _uuid = const Uuid();

  @override
  FutureOr<List<Map<String, dynamic>>> build() {
    return [];
  }

  Future<void> sendMessage(String input) async {
    final previousMessages = state.value ?? [];
    
    // 🔹 STEP 1 – UUID Generation
    final userMessage = {
      "id": _uuid.v4(),
      "role": "user",
      "content": input,
    };

    // Optimistically add the user message
    state = AsyncData([...previousMessages, userMessage]);

    state = await AsyncValue.guard(() async {
      final currentList = state.value ?? [];
      final service = ref.read(copilotServiceProvider);
      const String selectedModel = "claude-sonnet-4-5-20250929";

      // 🔹 STEP 2 – Capture Full History (Web Parity)
      final payloadMessages = currentList.map((m) => {
        "id": m["id"],
        "role": m["role"],
        "content": m["content"],
      }).toList();

      print("🚀 FULL HISTORY BEING SENT (MATCHING WEB PAYLOAD):");
      print(jsonEncode(payloadMessages));

      // 🔹 STEP 3 – /chat/ Call (Including full history + model)
      final chatResponse = await service.sendChatMessage(
        messages: payloadMessages,
        id: _sessionId,
        selectedChatModel: selectedModel,
      );

      final String? requestId = chatResponse['request_id']?.toString();
      final String? sessionId = chatResponse['session_id']?.toString() ?? 
                               chatResponse['conversation_id']?.toString() ??
                               _sessionId;

      if (requestId == null) {
        throw Exception("Missing request_id from /chat/ response");
      }
      
      if (sessionId != null) {
        _sessionId = sessionId;
      }

      // 🔹 STEP 4 – /stream/ Call (Including same full history + model)
      // Stream handles delta text, balance updates, and 'done' signal
      String assistantReply = "";
      try {
        assistantReply = await service.triggerStream(
          id: _sessionId ?? "",
          requestId: requestId,
          messages: payloadMessages,
          selectedChatModel: selectedModel,
        );
      } catch (e) {
        if (e.toString().contains("INSUFFICIENT_BALANCE")) {
          final assistantMessage = {
            "id": _uuid.v4(),
            "role": "assistant",
            "content": "Minimum balance of ₹50 required. Please recharge to continue.",
          };
          // Invalidate payment balance to update credits UI
          ref.invalidate(paymentBalanceProvider);
          return [...currentList, assistantMessage];
        }
        rethrow;
      }

      // 🔹 STEP 5 – Polling History for Persistence (Safe Sync)
      // The backend may take a moment to persist the final structured strategy object.
      print("🔄 Polling history for final structured strategy...");
      List<dynamic> history = [];
      dynamic lastMsg;
      int pollAttempts = 0;
      const int maxPollAttempts = 5;
      const Duration pollDelay = Duration(milliseconds: 800);

      while (pollAttempts < maxPollAttempts) {
        final response = await service.fetchChatHistory(sessionId: _sessionId);
        
        List<dynamic> messages;
        if (response is Map && response['messages'] is List) {
          messages = response['messages'] as List<dynamic>;
        } else if (response is List) {
          messages = response;
        } else {
          messages = [];
        }
        history = messages;

        print("========== FULL HISTORY RAW ==========");
        print(jsonEncode(response));
        print("=======================================");

        lastMsg = history.lastWhere((m) => m['role'] == 'assistant', orElse: () => null);

        if (lastMsg != null) {
          final bool hasStructuredData = 
              lastMsg['python'] != null || 
              lastMsg['strategy_json'] != null ||
              lastMsg['pine_script'] != null ||
              lastMsg['backtest_result'] != null ||
              lastMsg['metrics'] != null;

          if (hasStructuredData) {
            print("🎯 Structured data found after ${pollAttempts + 1} attempts!");
            break;
          }
        }

        pollAttempts++;
        if (pollAttempts < maxPollAttempts) {
          print("⏳ Waiting for persistence (Attempt $pollAttempts)...");
          await Future.delayed(pollDelay);
        }
      }

      final assistantMessage = {
        "id": _uuid.v4(),
        "role": "assistant",
        "content": assistantReply.isEmpty ? (lastMsg?['content'] ?? "No response from AI") : assistantReply,
        "python": lastMsg?['python'],
        "strategy_json": lastMsg?['strategy_json'] ?? lastMsg?['json'],
        "pine_script": lastMsg?['pine_script'],
        "backtest_result": lastMsg?['backtest_result'],
        "metrics": lastMsg?['metrics'],
      };

      print("✅ RECEIVED AI REPLY & STRUCTURED DATA SYNCED");

      // Invalidate payment balance to update credits UI
      ref.invalidate(paymentBalanceProvider);

      return [...currentList, assistantMessage];
    });
  }

  Future<void> loadSession(String sessionId) async {
    _sessionId = sessionId;
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      final service = ref.read(copilotServiceProvider);
      final response = await service.fetchChatHistory(sessionId: sessionId);
      
      List<dynamic> messageList;
      if (response is Map && response['messages'] is List) {
        messageList = response['messages'] as List<dynamic>;
      } else if (response is List) {
        messageList = response;
      } else {
        messageList = [];
      }

      // Map history messages to the expected format
      return messageList.map((e) {
        final Map<String, dynamic> msg = Map<String, dynamic>.from(e);
        // Ensure keys match what UI expects: 'role', 'content'
        return {
          "id": msg['id'] ?? msg['message_id'] ?? _uuid.v4(),
          "role": msg['role'] ?? (msg['is_user'] == true ? 'user' : 'assistant'),
          "content": msg['content'] ?? msg['text'] ?? '',
          "python": msg['python'],
          "strategy_json": msg['strategy_json'] ?? msg['json'],
          "pine_script": msg['pine_script'],
          "backtest_result": msg['backtest_result'],
          "metrics": msg['metrics'],
        };
      }).toList();
    });
  }

  void clearChat() {
    state = const AsyncData([]);
    _sessionId = null;
  }
}

final copilotProvider = AsyncNotifierProvider<CopilotNotifier, List<Map<String, dynamic>>>(() {
  return CopilotNotifier();
});
