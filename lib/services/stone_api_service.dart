import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import '../models/stone_scan_response.dart';
import '../models/stone_history_response.dart';
import '../models/stone_submission_response.dart';
import '../models/stone_list_response.dart';
import '../models/user_stats_response.dart';
import '../models/chat_request.dart';
import '../models/chat_response.dart';

class StoneApiService {
  static const String _baseUrl = 'https://skow40scksc88o4kwgwg40go.mobinaz.work/';
  static const Duration _timeout = Duration(seconds: 60); // Increased timeout for AI processing
  
  late final Dio _dio;
  String? _userId;
  String _locale = 'en';
  
  StoneApiService({String? userId, String locale = 'en'}) {
    _userId = userId;
    _locale = locale;
    
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-locale': locale,
      },
    ));
    
    // Add interceptors for logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }
  
  // Update user ID for authenticated requests
  void setUserId(String userId) {
    _userId = userId;
  }
  
  // Update locale for localized responses
  void setLocale(String locale) {
    _locale = locale;
    // Update header in dio instance
    _dio.options.headers['x-locale'] = locale;
  }
  
  // Get default headers for authenticated requests
  Map<String, dynamic> get _authHeaders => {
    if (_userId != null) 'X-User-Id': _userId!,
    'X-Locale': _locale,
  };
  
  /// Health check endpoint
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200 && response.data['status'] == 'OK';
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }
  
  /// Scan a stone/crystal image for identification
  Future<StoneScanResponse> scanStone({
    required File imageFile,
    String scanType = 'identification',
  }) async {
    try {
      if (_userId == null) {
        throw Exception('User ID is required for scanning stones');
      }
      
      // Determine content type based on file extension
      String? contentType;
      final extension = imageFile.path.toLowerCase().split('.').last;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'heic':
          contentType = 'image/heic';
          break;
        default:
          contentType = 'image/jpeg'; // fallback
      }
      
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'stone_image.$extension',
          contentType: MediaType.parse(contentType),
        ),
        'scan_type': scanType,
      });
      
      final response = await _dio.post(
        '/api/stones/scan',
        data: formData,
        options: Options(
          headers: _authHeaders,
          contentType: 'multipart/form-data',
        ),
      );
      
      // Debug: Log raw API response
      debugPrint('=== RAW API RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Data Type: ${response.data.runtimeType}');
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        debugPrint('Has html_content: ${data.containsKey('data') && data['data'] != null && data['data']['stone'] != null && data['data']['stone']['html_content'] != null}');
        if (data.containsKey('data') && data['data'] != null && data['data']['stone'] != null && data['data']['stone']['html_content'] != null) {
          final htmlContent = data['data']['stone']['html_content'] as String;
          debugPrint('HTML Content Length: ${htmlContent.length}');
          debugPrint('HTML Content Preview: ${htmlContent.substring(0, htmlContent.length > 200 ? 200 : htmlContent.length)}...');
        }
      }
      debugPrint('=== END RAW API RESPONSE ===');
      
      return StoneScanResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Get stone scanning history for the authenticated user
  Future<StoneHistoryResponse> getHistory({int limit = 50}) async {
    try {
      if (_userId == null) {
        throw Exception('User ID is required for fetching history');
      }
      
      final response = await _dio.get(
        '/api/stones/history',
        queryParameters: {'limit': limit},
        options: Options(headers: _authHeaders),
      );
      
      return StoneHistoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Get detailed information about a specific submission
  Future<StoneSubmissionResponse> getSubmissionDetails(int submissionId) async {
    try {
      if (_userId == null) {
        throw Exception('User ID is required for fetching submission details');
      }
      
      final response = await _dio.get(
        '/api/stones/submission/$submissionId',
        options: Options(headers: _authHeaders),
      );
      
      return StoneSubmissionResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Get all available stones in the database
  Future<StoneListResponse> getStonesList() async {
    try {
      final response = await _dio.get('/api/stones/list');
      
      return StoneListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Get user statistics
  Future<UserStatsResponse> getUserStats() async {
    try {
      if (_userId == null) {
        throw Exception('User ID is required for fetching user stats');
      }
      
      final response = await _dio.get(
        '/api/stones/stats',
        options: Options(headers: _authHeaders),
      );
      
      return UserStatsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Send a chat message to AI Stone Expert
  Future<ChatResponse> sendChatMessage({
    required String message,
    String? context,
    String? sessionId,
  }) async {
    try {
      if (_userId == null) {
        throw Exception('User ID is required for chat');
      }
      
      final chatRequest = ChatRequest(
        message: message,
        context: context ?? 'crystal_expert',
        sessionId: sessionId,
        locale: _locale,
      );
      
      // Log request details
      final requestData = chatRequest.toJson();
      final headers = {
        ..._authHeaders,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      debugPrint('=== CHAT API REQUEST ===');
      debugPrint('URL: ${_baseUrl}api/stones/chat');
      debugPrint('Headers: $headers');
      debugPrint('Body: $requestData');
      debugPrint('User ID: $_userId');
      debugPrint('Locale: $_locale');
      debugPrint('Context: ${requestData['context']}');
      debugPrint('Message: ${requestData['message']}');
      
      final response = await _dio.post(
        '/api/stones/chat',
        data: requestData,
        options: Options(headers: headers),
      );
      
      debugPrint('=== CHAT API RESPONSE ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Data Type: ${response.data.runtimeType}');
      debugPrint('Data: ${response.data}');
      debugPrint('Data Length: ${response.data.toString().length} bytes');
      
      return ChatResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Chat API Error: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }
  
  /// Handle Dio errors and convert to user-friendly messages
  Exception _handleDioError(DioException error) {
    String message = 'An unexpected error occurred';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        if (error.response?.data != null && error.response?.data['message'] != null) {
          message = error.response!.data['message'];
        } else {
          switch (error.response?.statusCode) {
            case 400:
              message = 'Bad request. Please check your input.';
              break;
            case 401:
              message = 'Unauthorized. Please authenticate.';
              break;
            case 403:
              message = 'Forbidden. You don\'t have permission to access this resource.';
              break;
            case 404:
              message = 'Resource not found.';
              break;
            case 413:
              message = 'Image file is too large. Maximum size is 10MB.';
              break;
            case 500:
              message = 'Server error. Please try again later.';
              break;
            default:
              message = 'Server error: ${error.response?.statusCode}';
          }
        }
        break;
      case DioExceptionType.connectionError:
        message = 'Cannot connect to server. Please check your internet connection.';
        break;
      default:
        message = error.message ?? 'An unexpected error occurred';
    }
    
    debugPrint('API Error: $message');
    debugPrint('Error details: ${error.toString()}');
    
    return Exception(message);
  }
  
  /// Dispose of resources
  void dispose() {
    _dio.close();
  }
}