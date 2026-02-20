import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_advanced/sms_advanced.dart';

import '../domain/entities/incident.dart';

class SmsService {
  final SmsSender _sender = SmsSender();

  /// Request SMS permission from the user (Android 6+)
  Future<bool> _requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Format incident data into the structured SMS format:
  /// [TYPE] [LAT],[LNG] [DESCRIPTION]
  String formatMessage({
    required IncidentType type,
    required double latitude,
    required double longitude,
    required String description,
  }) {
    final lat = latitude.toStringAsFixed(4);
    final lng = longitude.toStringAsFixed(4);
    return '${type.serverValue} $lat,$lng $description';
  }

  /// Send an SMS report to the gateway number.
  /// Requires SEND_SMS permission.
  Future<void> sendReport({
    required String gatewayNumber,
    required IncidentType type,
    required double latitude,
    required double longitude,
    required String description,
  }) async {
    // Request SMS permission if needed
    final hasPermission = await _requestSmsPermission();
    if (!hasPermission) {
      throw Exception('SMS permission denied by user. Unable to send report.');
    }

    final message = formatMessage(
      type: type,
      latitude: latitude,
      longitude: longitude,
      description: description,
    );

    try {
      final sms = SmsMessage(gatewayNumber, message);
      await _sender.sendSms(sms);
    } catch (e) {
      // Re-throw with more context
      throw Exception('Failed to send SMS via package: ${e.toString()}');
    }
  }
}

final smsServiceProvider = Provider<SmsService>((ref) {
  return SmsService();
});
