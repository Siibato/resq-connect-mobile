import 'package:flutter/material.dart';

import '../../../domain/entities/incident.dart';

class IncidentStatusBadge extends StatelessWidget {
  final IncidentStatus status;

  const IncidentStatusBadge({
    super.key,
    required this.status,
  });

  Color get _backgroundColor {
    switch (status) {
      case IncidentStatus.pending:
        return Colors.grey.shade200;
      case IncidentStatus.acknowledged:
        return Colors.amber.shade100;
      case IncidentStatus.inProgress:
        return Colors.amber.shade100;
      case IncidentStatus.resolved:
        return Colors.blue.shade100;
    }
  }

  Color get _textColor {
    switch (status) {
      case IncidentStatus.pending:
        return Colors.grey.shade700;
      case IncidentStatus.acknowledged:
        return Colors.amber.shade700;
      case IncidentStatus.inProgress:
        return Colors.amber.shade700;
      case IncidentStatus.resolved:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}
