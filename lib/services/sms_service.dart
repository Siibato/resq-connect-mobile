import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sms_advanced/sms_advanced.dart';

import '../domain/entities/incident.dart';

class SmsService {
  final SmsSender _sender = SmsSender();

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
  Future<void> sendReport({
    required String gatewayNumber,
    required IncidentType type,
    required double latitude,
    required double longitude,
    required String description,
  }) async {
    final message = formatMessage(
      type: type,
      latitude: latitude,
      longitude: longitude,
      description: description,
    );

    final sms = SmsMessage(gatewayNumber, message);
    await _sender.sendSms(sms);
  }
}

final smsServiceProvider = Provider<SmsService>((ref) {
  return SmsService();
});
