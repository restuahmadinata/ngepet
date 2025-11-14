import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

/// HTTP Client with timeout and retry mechanism configuration
class AppHttpClient {
  static final AppHttpClient _instance = AppHttpClient._internal();
  factory AppHttpClient() => _instance;
  AppHttpClient._internal();

  http.Client get client => _client;
  
  final http.Client _client = http.Client();

  /// Timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// POST request with error handling
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    int maxRetries = 2,
  }) async {
    int retryCount = 0;
    
    while (retryCount <= maxRetries) {
      try {
        final response = await _client
            .post(url, headers: headers, body: body)
            .timeout(receiveTimeout);
        return response;
      } on SocketException catch (e) {
        print('❌ SocketException (attempt ${retryCount + 1}/$maxRetries): $e');
        if (retryCount == maxRetries) rethrow;
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      } on TimeoutException catch (e) {
        print('❌ TimeoutException (attempt ${retryCount + 1}/$maxRetries): $e');
        if (retryCount == maxRetries) rethrow;
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      } on HttpException catch (e) {
        print('❌ HttpException (attempt ${retryCount + 1}/$maxRetries): $e');
        if (retryCount == maxRetries) rethrow;
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      } catch (e) {
        print('❌ Unknown error (attempt ${retryCount + 1}/$maxRetries): $e');
        rethrow;
      }
    }
    
    throw Exception('Failed after $maxRetries retries');
  }

  /// GET request with error handling
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    int maxRetries = 2,
  }) async {
    int retryCount = 0;
    
    while (retryCount <= maxRetries) {
      try {
        final response = await _client
            .get(url, headers: headers)
            .timeout(receiveTimeout);
        return response;
      } on SocketException catch (e) {
        print('❌ SocketException (attempt ${retryCount + 1}/$maxRetries): $e');
        if (retryCount == maxRetries) rethrow;
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      } on TimeoutException catch (e) {
        print('❌ TimeoutException (attempt ${retryCount + 1}/$maxRetries): $e');
        if (retryCount == maxRetries) rethrow;
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      } on HttpException catch (e) {
        print('❌ HttpException (attempt ${retryCount + 1}/$maxRetries): $e');
        if (retryCount == maxRetries) rethrow;
        retryCount++;
        await Future.delayed(Duration(seconds: retryCount * 2));
      } catch (e) {
        print('❌ Unknown error (attempt ${retryCount + 1}/$maxRetries): $e');
        rethrow;
      }
    }
    
    throw Exception('Failed after $maxRetries retries');
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}
