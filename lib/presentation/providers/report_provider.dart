import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/report.dart';
import 'report_state.dart';

final reportNotifierProvider =
    NotifierProvider<ReportNotifier, ReportState>(ReportNotifier.new);

class ReportNotifier extends Notifier<ReportState> {
  final List<Report> _reports = [];
  Report? _currentReport;

  @override
  ReportState build() {
    return const ReportState.initial();
  }

  List<Report> get reports => List.unmodifiable(_reports);
  Report? get currentReport => _currentReport;

  Future<void> submitReport(Report report) async {
    state = const ReportState.loading();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    _currentReport = report;
    _reports.add(report);
    state = ReportState.submitted(report);
  }

  void reset() {
    state = const ReportState.initial();
  }
}
