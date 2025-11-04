import 'package:intl/intl.dart';

/// Converts ISO 8601 date string to formatted string "MMMM dd, yyyy"
/// Example: "2025-11-03T16:00:00.000Z" -> "November 03, 2025"
String formatIsoDateToDisplay(String? isoDateString) {
  if (isoDateString == null || isoDateString.isEmpty) {
    return 'Unknown Date';
  }

  try {
    final DateTime dateTime = DateTime.parse(isoDateString);
    return DateFormat('MMMM dd, yyyy').format(dateTime);
  } catch (e) {
    print('DateUtils: Failed to parse date "$isoDateString": $e');
    return 'Invalid Date';
  }
}

/// Converts DateTime to formatted string "MMMM dd, yyyy"
String formatDateTimeToDisplay(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Unknown Date';
  }

  try {
    return DateFormat('MMMM dd, yyyy').format(dateTime);
  } catch (e) {
    print('DateUtils: Failed to format DateTime: $e');
    return 'Invalid Date';
  }
}

/// Converts Firestore timestamp format {_seconds, _nanoseconds} to formatted string
String formatFirestoreTimestampToDisplay(Map<String, dynamic>? timestamp) {
  if (timestamp == null) {
    return 'Unknown Date';
  }

  try {
    final seconds = timestamp['_seconds'] as int?;
    if (seconds != null) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
      return DateFormat('MMMM dd, yyyy').format(dateTime);
    }
    return 'Invalid Date';
  } catch (e) {
    print('DateUtils: Failed to parse Firestore timestamp: $e');
    return 'Invalid Date';
  }
}
