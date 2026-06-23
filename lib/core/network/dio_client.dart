import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import 'api_endpoints.dart';
import '../../main.dart';

class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor(),
      _errorInterceptor(),
      if (kDebugMode)
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
    ]);
  }

  Dio get dio => _dio;

  // Auth Interceptor - Add token to requests
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    );
  }

  // Error Interceptor - Handle errors globally
  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        // Handle 404 for specific GET requests (like ads) gracefully
        if (error.response?.statusCode == 404 && error.requestOptions.method == 'GET') {
           // Return empty data instead of error for specific endpoints or globally for GET
           // This prevents app crash when a resource list is empty/missing
           return handler.resolve(
             Response(
               requestOptions: error.requestOptions,
               data: {'success': true, 'data': []},
               statusCode: 200,
             ),
           );
        }

        if (error.response?.statusCode == 401) {
          // Token expired or invalid - logout user
          await _secureStorage.delete(key: AppConstants.tokenKey);
          await _secureStorage.delete(key: AppConstants.userKey);
          // Navigate to login using global navigator key
          _navigateToLogin();
        }
        return handler.next(error);
      },
    );
  }

  void _navigateToLogin() {
    final context = PharmaWayApp.navigatorKey.currentContext;
    if (context != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH Request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Multipart Request (for file uploads)
  Future<Response> postMultipart(
    String path, {
    required FormData formData,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handler
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.');
      
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      
      case DioExceptionType.cancel:
        return NetworkException('تم إلغاء الطلب.');
      
      default:
        return NetworkException('حدث خطأ في الاتصال. يرجى التحقق من الإنترنت.');
    }
  }

  Exception _handleResponseError(Response? response) {
    if (response == null) {
      return NetworkException('لا يوجد استجابة من الخادم.');
    }

    switch (response.statusCode) {
      case 400:
        return BadRequestException(
          response.data['message'] ?? 'طلب غير صحيح.',
        );
      case 401:
        return UnauthorizedException(
          response.data['message'] ?? 'غير مصرح. يرجى تسجيل الدخول مرة أخرى.',
        );
      case 403:
        return ForbiddenException(
          response.data['message'] ?? 'ليس لديك صلاحية للوصول.',
        );
      case 404:
        return NotFoundException(
          response.data['message'] ?? 'المورد غير موجود.',
        );
      case 422:
        return ValidationException(
          response.data['message'] ?? 'خطأ في التحقق من البيانات.',
          response.data['errors'] as Map<String, dynamic>?,
        );
      case 500:
        return ServerException(
          response.data['message'] ?? 'خطأ في الخادم. يرجى المحاولة لاحقاً.',
        );
      default:
        return NetworkException(
          'حدث خطأ غير متوقع (${response.statusCode}).',
        );
    }
  }
}

// Custom Exceptions
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
  
  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  
  @override
  String toString() => message;
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
  
  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  
  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  
  ValidationException(this.message, this.errors);
  
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  
  @override
  String toString() => message;
}

// Riverpod Provider
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});
