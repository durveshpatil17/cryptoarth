import 'package:dio/dio.dart';
import 'package:cryptoarth/core/network/api_client.dart';
import 'package:cryptoarth/core/network/api_endpoints.dart';
import 'package:cryptoarth/features/credits/models/payment_balance_model.dart';
import 'package:cryptoarth/features/credits/models/payment_ledger_model.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  Future<PaymentBalanceModel> fetchPaymentBalance() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.paymentLedger);
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = ApiClient.extractMap(response.data);
        return PaymentBalanceModel.fromJson(data);
      }
      throw Exception('Invalid backend response');
    } catch (e) {
      throw Exception('Failed to fetch payment balance: $e');
    }
  }

  Future<List<PaymentLedgerModel>> fetchPaymentLedger() async {
    try {
      final Response response = await _apiClient.get(ApiEndpoints.paymentLedger);
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        List<dynamic> allTransactions = [];
        if (body is Map) {
          if (body['credit_transactions'] is List) {
            final credits = (body['credit_transactions'] as List).map((e) {
               if (e is Map) e['transaction_type'] = 'CREDIT';
               return e;
            }).toList();
            allTransactions.addAll(credits);
          }
          if (body['debit_transactions'] is List) {
            final debits = (body['debit_transactions'] as List).map((e) {
               if (e is Map) e['transaction_type'] = 'DEBIT';
               return e;
            }).toList();
            allTransactions.addAll(debits);
          }
        } 
        
        if (allTransactions.isEmpty) {
           allTransactions = ApiClient.extractList(body);
        }

        final items = allTransactions.map((json) => PaymentLedgerModel.fromJson(json)).toList();
        
        // Sort newest first
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        return items;
      }
      throw Exception('Invalid backend response');
    } catch (e) {
      throw Exception('Failed to fetch payment ledger: $e');
    }
  }

  Future<Map<String, dynamic>> createOrder(num amount) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.paymentCreateOrder, {
        "amount": amount,
      });
      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        return response.data;
      }
      throw Exception('Failed to create order');
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<bool> verifyPayment(Map<String, dynamic> data) async {
    try {
      final Response response = await _apiClient.post(ApiEndpoints.paymentVerify, data);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to verify payment: $e');
    }
  }
}
