enum IncidentStatus { pending, acknowledged, inProgress, resolved }

enum IncidentType { fire, medical, police }

extension IncidentTypeExtension on IncidentType {
  String get serverValue {
    switch (this) {
      case IncidentType.fire:
        return 'FIRE';
      case IncidentType.medical:
        return 'MEDICAL';
      case IncidentType.police:
        return 'POLICE';
    }
  }

  String get displayName {
    switch (this) {
      case IncidentType.fire:
        return 'Fire Protection';
      case IncidentType.medical:
        return 'CDRRMO (Rescue)';
      case IncidentType.police:
        return 'Police';
    }
  }

  static IncidentType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'FIRE':
        return IncidentType.fire;
      case 'MEDICAL':
        return IncidentType.medical;
      case 'POLICE':
        return IncidentType.police;
      default:
        return IncidentType.police;
    }
  }
}

extension IncidentStatusExtension on IncidentStatus {
  String get displayName {
    switch (this) {
      case IncidentStatus.pending:
        return 'Received';
      case IncidentStatus.acknowledged:
        return 'In Progress';
      case IncidentStatus.inProgress:
        return 'In Progress';
      case IncidentStatus.resolved:
        return 'Resolved';
    }
  }

  static IncidentStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return IncidentStatus.pending;
      case 'ACKNOWLEDGED':
        return IncidentStatus.acknowledged;
      case 'IN_PROGRESS':
        return IncidentStatus.inProgress;
      case 'RESOLVED':
        return IncidentStatus.resolved;
      default:
        return IncidentStatus.pending;
    }
  }
}

class Incident {
  final String id;
  final IncidentType type;
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final IncidentStatus status;
  final String? priority;
  final String? reporterName;
  final DateTime? createdAt;
  final List<String> mediaUrls;

  const Incident({
    required this.id,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.status,
    this.priority,
    this.reporterName,
    this.createdAt,
    this.mediaUrls = const [],
  });

  String get displayLocation {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    if (latitude == 0.0 && longitude == 0.0) {
      return 'Location not available';
    }
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  Incident copyWith({
    String? id,
    IncidentType? type,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    IncidentStatus? status,
    String? priority,
    String? reporterName,
    DateTime? createdAt,
    List<String>? mediaUrls,
  }) {
    return Incident(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      reporterName: reporterName ?? this.reporterName,
      createdAt: createdAt ?? this.createdAt,
      mediaUrls: mediaUrls ?? this.mediaUrls,
    );
  }
}
