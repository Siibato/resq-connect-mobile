class ApiConstants {
  ApiConstants._();

  // Base paths
  static const String authBase = '/api/auth';
  static const String incidentsBase = '/api/incidents';
  static const String usersBase = '/api/users';
  static const String smsGatewayBase = '/api/sms-gateway';
  static const String respondersBase = '/api/responders';
  static const String mediaBase = '/api/media';
  static const String analyticsBase = '/api/analytics';
  static const String adminBase = '/api/admin';

  // Auth endpoints
  static const String register = '$authBase/register';
  static const String login = '$authBase/login';
  static const String verifyOtp = '$authBase/verify-otp';
  static const String resendOtp = '$authBase/resend-otp';
  static const String refresh = '$authBase/refresh';
  static const String profile = '$authBase/profile';
  static const String changePassword = '$authBase/change-password';

  // Incidents endpoints
  static const String createIncident = incidentsBase;
  static const String myReports = '$incidentsBase/my-reports';
  static const String assignedIncidents = '$incidentsBase/assigned';
  static String incidentDetail(String id) => '$incidentsBase/$id';
  static String incidentFeedback(String id) => '$incidentsBase/$id/feedback';
  static String incidentStatus(String id) => '$incidentsBase/$id/status';
  static String incidentResponseSummary(String id) => '$incidentsBase/$id/response-summary';
  static String incidentAssign(String id) => '$incidentsBase/$id/assign';
  static String incidentPriority(String id) => '$incidentsBase/$id/priority';
  static String incidentType(String id) => '$incidentsBase/$id/type';
  static String incidentTimeline(String id) => '$incidentsBase/$id/timeline';

  // Users endpoints
  static const String users = usersBase;
  static String userDetail(String id) => '$usersBase/$id';
  static String userStatus(String id) => '$usersBase/$id/status';

  // SMS Gateway endpoints
  static const String smsWebhook = '$smsGatewayBase/webhook';
  static const String smsSend = '$smsGatewayBase/send';
  static const String smsReports = '$smsGatewayBase/reports';
  static String smsReportDetail(String id) => '$smsGatewayBase/reports/$id';

  // Responders endpoints
  static const String responders = respondersBase;
  static String responderDetail(String id) => '$respondersBase/$id';
  static String responderPerformance(String id) => '$respondersBase/$id/performance';

  // Media endpoints
  static const String mediaUpload = '$mediaBase/upload';
  static String mediaServe(String id) => '$mediaBase/$id';
  static String mediaDelete(String id) => '$mediaBase/$id';

  // Analytics endpoints
  static const String analyticsOverview = '$analyticsBase/overview';
  static const String analyticsResponseTimes = '$analyticsBase/response-times';
  static const String analyticsHotspots = '$analyticsBase/hotspots';
  static const String analyticsTrends = '$analyticsBase/trends';
  static const String analyticsByType = '$analyticsBase/by-type';
  static const String analyticsByAgency = '$analyticsBase/by-agency';
  static const String analyticsExport = '$analyticsBase/export';

  // Admin endpoints
  static const String adminDashboard = '$adminBase/dashboard';
  static const String adminLgus = '$adminBase/lgus';
  static String adminLguDetail(String id) => '$adminBase/lgus/$id';
  static const String adminSystemLogs = '$adminBase/system-logs';
  static const String adminSystemSettings = '$adminBase/system-settings';
}