class OfflineReport {
  final String id;
  final String citizenId;
  final String citizenName;
  final String type; // FIRE, MEDICAL, POLICE
  final double latitude;
  final double longitude;
  final String description;
  final String smsText;
  final String status; // DRAFT, SENT
  final DateTime createdAt;
  final DateTime? sentAt;

  const OfflineReport({
    required this.id,
    required this.citizenId,
    required this.citizenName,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.smsText,
    required this.status,
    required this.createdAt,
    this.sentAt,
  });

  factory OfflineReport.fromJson(Map<String, dynamic> json) {
    return OfflineReport(
      id: json['id'] as String,
      citizenId: json['citizen_id'] as String,
      citizenName: json['citizen_name'] as String,
      type: json['type'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      description: json['description'] as String,
      smsText: json['sms_text'] as String,
      status: json['status'] as String? ?? 'DRAFT',
      createdAt: DateTime.parse(json['created_at'] as String),
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'citizen_id': citizenId,
      'citizen_name': citizenName,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'sms_text': smsText,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'sent_at': sentAt?.toIso8601String(),
    };
  }

  OfflineReport copyWith({
    String? id,
    String? citizenId,
    String? citizenName,
    String? type,
    double? latitude,
    double? longitude,
    String? description,
    String? smsText,
    String? status,
    DateTime? createdAt,
    DateTime? sentAt,
  }) {
    return OfflineReport(
      id: id ?? this.id,
      citizenId: citizenId ?? this.citizenId,
      citizenName: citizenName ?? this.citizenName,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      smsText: smsText ?? this.smsText,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
    );
  }

  String get formattedSmsText => smsText;

  bool get isDraft => status == 'DRAFT';
  bool get isSent => status == 'SENT';
}
