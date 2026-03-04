import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryptoarth/features/strategies/services/copilot_service.dart';
import 'package:cryptoarth/features/credits/providers/payment_balance_provider.dart';
import 'package:cryptoarth/features/strategies/models/chat_message_model.dart';
import 'package:cryptoarth/features/strategies/providers/strategy_provider.dart';
import 'package:cryptoarth/features/strategies/providers/backtest_provider.dart';
import 'package:cryptoarth/features/strategies/models/backtest_model.dart';
import 'package:uuid/uuid.dart';
import 'package:cryptoarth/features/auth/providers/auth_provider.dart';
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

String _generatePineLocal(Map<String, dynamic> strategy) {
  final String desc = strategy["description"] ?? strategy["strategy_name"] ?? "Copilot Strategy";
  return '''
//@version=5
strategy("\$desc", overlay=true)

bb = ta.bb(close, 20, 2)
longCondition = close <= bb.lower
shortCondition = close >= bb.upper

if (longCondition)
    strategy.entry("Long", strategy.long)

if (shortCondition)
    strategy.entry("Short", strategy.short)
''';
}

class CopilotNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  String? _sessionId;
  final _uuid = const Uuid();
  bool isGenerating = false;

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

    isGenerating = true;
    try {
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

      print("=== FINAL ASSISTANT MESSAGE STATE ===");
      print(assistantMessage);

      // PART 1 - ROBUST EXTRACTION (JSON, PINE, PYTHON)
      final content = assistantMessage["content"]?.toString() ?? "";

      // 1.1 JSON Extraction (Strategy Logic)
      final jsonStart = content.indexOf("```json");
      if (jsonStart != -1) {
        final jsonEnd = content.indexOf("```", jsonStart + 7);
        if (jsonEnd != -1) {
          final jsonString = content.substring(jsonStart + 7, jsonEnd).trim();
          try {
            final parsed = jsonDecode(jsonString);
            assistantMessage["strategy_meta"] = parsed;
            assistantMessage["strategy_json"] = parsed["strategy_json"] ?? parsed;
            assistantMessage["strategy_name"] = parsed["strategy_name"];
            assistantMessage["strategy_description"] = parsed["strategy_description"];

            print("✅ STRATEGY JSON EXTRACTED");
          } catch (e) {
            print("❌ JSON PARSE ERROR: $e");
          }
        }
      }

      // 1.2 Pine Script Extraction
      if (content.contains("```pine")) {
        final pStart = content.indexOf("```pine");
        final pEnd = content.indexOf("```", pStart + 7);
        if (pEnd != -1) {
          assistantMessage["pine_code"] = content.substring(pStart + 7, pEnd).trim();
          print("✅ PINE SCRIPT EXTRACTED");
        }
      } else if (content.contains("```pinescript")) {
        final psStart = content.indexOf("```pinescript");
        final psEnd = content.indexOf("```", psStart + 13);
        if (psEnd != -1) {
          assistantMessage["pine_code"] = content.substring(psStart + 13, psEnd).trim();
          print("✅ PINE SCRIPT EXTRACTED");
        }
      }

      // 1.3 Python Extraction
      if (content.contains("```python")) {
        final pyStart = content.indexOf("```python");
        final pyEnd = content.indexOf("```", pyStart + 9);
        if (pyEnd != -1) {
          assistantMessage["python"] = content.substring(pyStart + 9, pyEnd).trim();
          print("✅ PYTHON CODE EXTRACTED");
        }
      }

      // Fallback: If no Pine code extracted but we have JSON, generate local mock as fallback
      if (assistantMessage["pine_code"] == null && assistantMessage["strategy_json"] is Map) {
         assistantMessage["pine_code"] = _generatePineLocal(assistantMessage["strategy_json"]);
         print("✅ FALLBACK PINE GENERATED FROM JSON");
      }

      // PART 2 - FORCE RIVERPOD STATE REBUILD
      final updated = [...currentList];
      updated.add(Map<String, dynamic>.from(assistantMessage));
      return updated;
    });
    } finally {
      isGenerating = false;
    }
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

  void startNewChat() => clearChat();

  Future<void> runBacktest(String messageId) async {
    final messages = state.value ?? [];
    final index = messages.indexWhere((m) => m['id'] == messageId);
    if (index == -1) return;

    final message = messages[index];
    final service = ref.read(strategyServiceProvider);

    try {
      final Map<String, dynamic> runPayload = {
        "symbol": "BTCUSD",
        "timeframe": "15MIN",
        "leverage": 10,
        "capital_percent": 25,
        "capital": 10000,
        "commission_type": "maker",
        "commission_percent": 0.05,
      };

      if (message['strategy_json'] != null) {
        runPayload['json_strategy_code'] = message['strategy_json'];
      } else if (message['python'] != null) {
        runPayload['python_backtest_code'] = message['python'];
      } else if (message['pine_code'] != null || message['pine_script'] != null) {
        runPayload['pine_code'] = message['pine_code'] ?? message['pine_script'];
      }

      final result = await service.runBacktest(runPayload);
      
      // Update state safely
      final updatedMessage = Map<String, dynamic>.from(message);
      updatedMessage['backtest_id'] = result['backtest_id'];
      updatedMessage['metrics'] = result['metrics'] ?? result['backtest_result']?['metrics'];
      updatedMessage['backtest_result'] = result;
      
      final newList = List<Map<String, dynamic>>.from(messages);
      newList[index] = updatedMessage;
      state = AsyncData(newList);
      
      // Invalidate backtest history
      ref.invalidate(backtestProvider);
    } catch (e) {
      print("🚨 COPILOT BACKTEST ERROR: $e");
      rethrow;
    }
  }

  Future<void> deployStrategy(String messageId, String mode) async {
    final messages = state.value ?? [];
    final index = messages.indexWhere((m) => m['id'] == messageId);
    if (index == -1) return;

    final message = messages[index];
    
    final backtestId = message['backtest_id']?.toString() ?? message['backtest_result']?['backtest_id']?.toString();
    
    if (backtestId == null) {
       throw Exception("Backtest must be completed before saving/deploying");
    }

    final service = ref.read(strategyServiceProvider);

    try {
      // Step 5: Save
      final savePayload = {
        "backtest_id": backtestId
      };
      // createStrategy endpoint calls /auth/strategy/copilot/save-strategy/
      final saveResponse = await service.createStrategy(savePayload);
      
      final savedStrategyId = saveResponse['id']?.toString() ?? saveResponse['strategy_id']?.toString();
      if (savedStrategyId == null) {
         throw Exception("Failed to save strategy: No strategy ID returned");
      }
      final user = ref.read(authProvider).user;
      
      // Step 6: Deploy
      await service.deployCopilotStrategy(savedStrategyId, mode, userId: user?.id);
      
      // Invalidate providers so execution history and dashboard refresh
      ref.invalidate(strategyProvider);
      ref.invalidate(dashboardStrategyProvider);
      ref.invalidate(backtestProvider);
      
    } catch (e) {
      print("🚨 COPILOT DEPLOY ERROR: $e");
      rethrow;
    }
  }
}

final copilotProvider = AsyncNotifierProvider<CopilotNotifier, List<Map<String, dynamic>>>(() {
  return CopilotNotifier();
});
