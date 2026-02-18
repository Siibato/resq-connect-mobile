import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';

class HealthCheckService {
  final DioClient _dioClient;

  HealthCheckService(this._dioClient);

  /// Checks if server is reachable
  /// Returns true if server responds within timeout, false otherwise
  Future<bool> isServerReachable({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final response = await _dioClient.get(
        '/',
        options: Options(
          receiveTimeout: timeout,
          sendTimeout: timeout,
          validateStatus: (status) => true,
        ),
      );
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      return false;
    }
  }
}

final healthCheckServiceProvider = Provider<HealthCheckService>((ref) {
  return HealthCheckService(ref.watch(dioClientProvider));
});
