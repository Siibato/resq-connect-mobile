import '../../domain/entities/report.dart';

sealed class ReportState {
  const ReportState();

  const factory ReportState.initial() = ReportStateInitial;
  const factory ReportState.loading() = ReportStateLoading;
  const factory ReportState.submitted(Report report) = ReportStateSubmitted;
  const factory ReportState.error(String message) = ReportStateError;
}

class ReportStateInitial extends ReportState {
  const ReportStateInitial();
}

class ReportStateLoading extends ReportState {
  const ReportStateLoading();
}

class ReportStateSubmitted extends ReportState {
  final Report report;
  const ReportStateSubmitted(this.report);
}

class ReportStateError extends ReportState {
  final String message;
  const ReportStateError(this.message);
}
