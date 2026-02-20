import '../../domain/entities/incident.dart';

final Map<IncidentType, List<String>> incidentChoices = {
  IncidentType.police: [
    'Police assistance needed for a disturbance.',
    'Suspicious activity reported; need police help.',
    'Fight broke out, police response needed.',
  ],
  IncidentType.medical: [
    'Rescue team needed for an accident.',
    'Medical emergency; please send help.',
    'Flood report, immediate rescue needed.',
    'Fallen tree blocking road; need assistance.',
  ],
  IncidentType.fire: [
    'Fire report, send firefighters immediately.',
    'Electrical fire report, urgent help required.',
    'Grass fire spreading; send fire team now.',
  ],
};
