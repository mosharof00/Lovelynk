import 'package:intl/intl.dart';

class FormatTime {
  static String dateMonthYear(String date) {
    final month = DateFormat('MMMM').format(DateTime.parse(date));
    final day = DateFormat('d').format(DateTime.parse(date));
    final year = DateFormat('y').format(DateTime.parse(date));
    return '$day $month, $year';
  }

  /// Parse Time
  static String parseTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Format Time group By
  static String groupByDate(DateTime? date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (date == null) return 'Unknown';
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateToCheck).inDays < 7) {
      return 'This Week';
    } else if (now.difference(dateToCheck).inDays < 30) {
      return 'This Month';
    } else {
      return DateFormat('MMMM yyyy').format(date);
    }
  }

  static int groupComparator(String value1, String value2) {
    final priority = {
      'Today': 0,
      'Yesterday': 1,
      'This Week': 2,
    };
    final p1 =
        priority[value1] ?? 3; // Default to 'Older' if not in the priority list
    final p2 = priority[value2] ?? 3;
    return p1.compareTo(p2);
  }

  /// Format Time Ago
  static String timeAgo(DateTime dateTime) {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Calculate the difference between now and the posted date
    Duration difference = now.difference(dateTime);

    // Determine the time difference in various units
    if (difference.inDays >= 30) {
      int months = (difference.inDays / 30).floor();
      return '$months month ago';
    } else if (difference.inDays >= 7) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks week ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} day ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} min ago';
    } else {
      return 'now';
    }
  }

  static String formatAmPmTime({required String time}) {
    DateTime dateTime = DateTime.parse("1970-01-01 $time");
    int hour = dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12; // Convert to 12-hour format
    String period = dateTime.hour >= 12 ? "PM" : "AM";
    String minute =
        dateTime.minute.toString().padLeft(2, '0'); // Ensure two-digit minutes
    return "$hour:$minute $period";
  }

  static String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 3) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy')
          .format(dateTime); // Example: "05 Feb 2024"
    }
  }

  static String getLastWeekRange() {
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(Duration(days: 1)); // Yesterday
    DateTime lastWeekStart = today.subtract(Duration(days: 7)); // 7 Days Ago

    String formattedStart = DateFormat('MMM d').format(lastWeekStart);
    String formattedEnd = DateFormat('MMM d').format(yesterday);

    return "This Week ($formattedStart - $formattedEnd)";
  }
}
