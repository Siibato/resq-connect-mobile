import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../constants/api_constants.dart';
import '../constants/env_config.dart';
import '../errors/exceptions.dart';
import '../../data/datasources/local/secure_storage.dart';
import '../../presentation/providers/auth_provider.dart';

class DioClient {
  final Dio _dio;
  final SecureStorage _secureStorage;
  final Logger _logger;

  /// Set this callback to be notified when auth is irrecoverably invalid.
  /// Hook into this to force-navigate to the login screen.
  void Function()? onForceLogout;

  DioClient({
    required Dio dio,
    required SecureStorage secureStorage,
    required Logger logger,
  })  : _dio = dio,
        _secureStorage = secureStorage,
        _logger = logger {
    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.options = BaseOptions(
      baseUrl: EnvConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
      receiveTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
      headers: {
        // Don't set global Content-Type - let each request handle it
        // This prevents conflicts with multipart/form-data for file uploads
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.addAll([
      _authInterceptor(),
      _contentTypeInterceptor(),
      _loggingInterceptor(),
      _errorInterceptor(),
    ]);
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        const publicEndpoints = [
          ApiConstants.register,
          ApiConstants.login,
          ApiConstants.verifyOtp,
          ApiConstants.resendOtp,
        ];

        if (!publicEndpoints.contains(options.path)) {
          final token = await _secureStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        handler.next(options);
      },
    );
  }

  InterceptorsWrapper _contentTypeInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Set Content-Type: application/json for non-multipart requests
        if (options.contentType == null ||
            !options.contentType.toString().contains('multipart')) {
          options.headers['Content-Type'] = 'application/json';
        }
        handler.next(options);
      },
    );
  }

  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.d(
          'REQUEST[${options.method}] => PATH: ${options.path}\n'
          'Headers: ${options.headers}\n'
          'Data: ${options.data}',
        );
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i(
          'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}\n'
          'Data: ${response.data}',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.e(
          'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}\n'
          'Message: ${error.message}\n'
          'Data: ${error.response?.data}',
        );
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Try to refresh the token before logging out
          try {
            final refreshToken = await _secureStorage.getRefreshToken();
            if (refreshToken != null) {
              // Attempt to refresh the access token
              final response = await _dio.post(
                ApiConstants.refresh,
                data: {'refreshToken': refreshToken},
                options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                  },
                ),
              );

              if (response.statusCode == 200) {
                final newAccessToken = response.data['accessToken'] as String?;
                if (newAccessToken != null) {
                  // Save new access token
                  await _secureStorage.saveAccessToken(newAccessToken);

                  // Retry the original request with new token
                  error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                  return handler.resolve(await _dio.request(
                    error.requestOptions.path,
                    options: Options(
                      method: error.requestOptions.method,
                      headers: error.requestOptions.headers,
                    ),
                    data: error.requestOptions.data,
                    queryParameters: error.requestOptions.queryParameters,
                  ));
                }
              }
            }
          } catch (e) {
            _logger.e('Token refresh failed: $e');
          }

          // If refresh failed or no refresh token, force logout
          await _secureStorage.clearAll();
          onForceLogout?.call();
        }
        handler.next(error);
      },
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please try again.');

      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network.');

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled.');

      default:
        return NetworkException('An unexpected error occurred.');
    }
  }

  Exception _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message = 'An error occurred';
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      final msgData = data['message'];
      // Handle both string and array responses
      if (msgData is String) {
        message = msgData;
      } else if (msgData is List) {
        // Join array messages with newlines
        message = msgData.map((e) => e.toString()).join('\n');
      } else {
        message = msgData.toString();
      }
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message);
      case 401:
        return UnauthorizedException(message);
      case 409:
        return ServerException(message, statusCode: statusCode);
      default:
        return ServerException(message, statusCode: statusCode);
    }
  }
}

final loggerProvider = Provider<Logger>((ref) => Logger());

final dioProvider = Provider<Dio>((ref) => Dio());

final dioClientProvider = Provider<DioClient>((ref) {
  final client = DioClient(
    dio: ref.watch(dioProvider),
    secureStorage: ref.watch(secureStorageProvider),
    logger: ref.watch(loggerProvider),
  );
  client.onForceLogout = () {
    ref.read(authNotifierProvider.notifier).logout();
  };
  return client;
});