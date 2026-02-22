import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';

class ApiClient {
  static final StreamController<void> authErrorStream = StreamController<void>.broadcast();

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  late Dio _dio;

  static List<dynamic> extractList(dynamic rawData) {
    if (rawData == null) return [];
    
    dynamic data = rawData;
    if (rawData is String) {
      try {
        data = jsonDecode(rawData);
      } catch (_) {
        return [];
      }
    }

    if (data is List) return data;
    if (data is Map) {
      final keys = ['ledger', 'data', 'results', 'transactions', 'strategies', 'deployed_strategies', 'backtests', 'positions', 'orders'];
      for (var key in keys) {
        if (data.containsKey(key) && data[key] is List) return data[key];
      }
      for (var value in data.values) {
        if (value is List) return value;
      }
    }
    return [];
  }

  static Map<String, dynamic> extractMap(dynamic rawData) {
    if (rawData == null) return {};
    
    dynamic data = rawData;
    if (rawData is String) {
      try {
        data = jsonDecode(rawData);
      } catch (_) {
        return {};
      }
    }

    if (data is Map<String, dynamic>) {
      if (data.containsKey('user') && data['user'] is Map) {
        return Map<String, dynamic>.from(data['user']);
      }
      if (data.containsKey('data') && data['data'] is Map) {
         return Map<String, dynamic>.from(data['data']);
      }
      return data;
    }
    if (data is Map) {
      if (data.containsKey('user') && data['user'] is Map) {
        return Map<String, dynamic>.from(data['user']);
      }
      if (data.containsKey('data') && data['data'] is Map) {
         return Map<String, dynamic>.from(data['data']);
      }
      if (data.containsKey('balance')) {
         return Map<String, dynamic>.from(data);
      }
      return Map<String, dynamic>.from(data);
    }

    return {};
  }

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print("🌐 API REQUEST [${options.method}] → ${options.uri}");
          if (options.data != null) print("📦 REQUEST BODY: ${options.data}");
          
          final token = await TokenStorage.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
            print("🔑 TOKEN INCLUDED (length: ${token.length})");
          }

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          print("✅ API RESPONSE [${response.statusCode}] → ${response.requestOptions.uri}");
          print("📄 RESPONSE DATA: ${response.data}");
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          print("❌ API ERROR [${error.response?.statusCode}] → ${error.requestOptions.uri}");
          print("📄 ERROR DATA: ${error.response?.data}");
          
          if (error.response?.statusCode == 401) {
            authErrorStream.add(null);
          }
          
          String message = "An unexpected error occurred.";
          if (error.response?.statusCode == 500 || error.response?.statusCode == 502 || error.response?.statusCode == 503) {
            message = "Server Error: Please try again later.";
          } else if (error.type == DioExceptionType.connectionTimeout || 
                     error.type == DioExceptionType.receiveTimeout || 
                     error.type == DioExceptionType.connectionError ||
                     error.type == DioExceptionType.unknown) {
            message = "Network Error: Please check your connection and try again.";
          } else if (error.response?.data is Map && error.response?.data['detail'] != null) {
            message = error.response?.data['detail'];
          } else if (error.response?.data is Map && error.response?.data['error'] != null) {
            message = error.response?.data['error'];
          } else if (error.response?.data is Map && error.response?.data['message'] != null) {
            message = error.response?.data['message'];
          } else if (error.response?.statusMessage != null) {
            message = error.response!.statusMessage!;
          }
          final customError = DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: message,
          );
          return handler.next(customError);
        },
      ),
    );
  }

  // GET
  Future<Response> get(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } on DioException catch (e) {
      print("API GET ERROR ENDPOINT → $endpoint");
      if (e.response != null) {
        print("API ERROR STATUS → ${e.response?.statusCode}");
        print("API ERROR DATA → ${e.response?.data}");
      } else {
        print("API ERROR MESSAGE → ${e.message}");
      }
      rethrow;
    } catch (e) {
      throw Exception("GET unknown error: $e");
    }
  }

  // POST
  Future<Response> post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        path,
        data: body,
      );
      return response;
    } on DioException catch (e) {
      print("API POST ERROR PATH → $path");

      if (e.response != null) {
        print("API ERROR STATUS → ${e.response?.statusCode}");
        print("API ERROR DATA → ${e.response?.data}");
        print("API ERROR HEADERS → ${e.response?.headers}");
      } else {
        print("API ERROR MESSAGE → ${e.message}");
      }

      rethrow;
    }
  }

  // PUT
  Future<Response> put(String endpoint, dynamic data) async {
    try {
      return await _dio.put(endpoint, data: data);
    } catch (e) {
      throw Exception("PUT error: $e");
    }
  }

  // PATCH
  Future<Response> patch(String endpoint, dynamic data) async {
    try {
      return await _dio.patch(endpoint, data: data);
    } catch (e) {
      throw Exception("PATCH error: $e");
    }
  }

  // DELETE
  Future<Response> delete(String endpoint) async {
    try {
      return await _dio.delete(endpoint);
    } catch (e) {
      throw Exception("DELETE error: $e");
    }
  }
}
