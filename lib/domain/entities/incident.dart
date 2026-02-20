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
        return 'Acknowledged';
      case IncidentStatus.inProgress:
        return 'In Progress';
      case IncidentStatus.resolved:
        return 'Resolved';
    }
  }

  /// Get the next valid transition for this status
  IncidentStatus? get nextTransition {
    switch (this) {
      case IncidentStatus.pending:
        return IncidentStatus.acknowledged;
      case IncidentStatus.acknowledged:
        return IncidentStatus.inProgress;
      case IncidentStatus.inProgress:
        return IncidentStatus.resolved;
      case IncidentStatus.resolved:
        return null; // No further transitions
    }
  }

  /// Get the server status string for the next transition
  String? get nextTransitionServerValue {
    final next = nextTransition;
    return next?.serverValue;
  }

  /// Get server status string
  String get serverValue {
    switch (this) {
      case IncidentStatus.pending:
        return 'PENDING';
      case IncidentStatus.acknowledged:
        return 'ACKNOWLEDGED';
      case IncidentStatus.inProgress:
        return 'IN_PROGRESS';
      case IncidentStatus.resolved:
        return 'RESOLVED';
    }
  }

  /// Check if a transition to another status is valid
  bool canTransitionTo(IncidentStatus target) {
    return nextTransition == target;
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
  final String? reporterMobile;
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
    this.reporterMobile,
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
    String? reporterMobile,
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
      reporterMobile: reporterMobile ?? this.reporterMobile,
      createdAt: createdAt ?? this.createdAt,
      mediaUrls: mediaUrls ?? this.mediaUrls,
    );
  }
}
