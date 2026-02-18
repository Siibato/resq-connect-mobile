import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    try {
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return date.toString();
    }
  }

  static String formatDateTime(DateTime dateTime) {
    try {
      return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
    } catch (_) {
      return dateTime.toString();
    }
  }

  static String formatTime(DateTime dateTime) {
    try {
      return DateFormat('HH:mm').format(dateTime);
    } catch (_) {
      return dateTime.toString();
    }
  }
}
