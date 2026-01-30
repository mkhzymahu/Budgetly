class DateHelpers {
  static List<String> getMonthYearOptions() {
    final List<String> options = [];
    final now = DateTime.now();

    // Show current month + 11 previous months (1 year range)
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i);
      options.add(_formatMonthYear(date));
    }

    return options;
  }

  static DateTime getDefaultDateForMonth(DateTime month) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // If selected month is in future, return today
    if (month.isAfter(currentMonth)) {
      return now;
    }

    // If selected month is current month, return today
    if (isSameMonth(month, now)) {
      return now;
    }

    // For past months, return 15th of that month
    return DateTime(month.year, month.month, 15);
  }

  static String _formatMonthYear(DateTime date) {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${monthNames[date.month - 1]} ${date.year}';
  }

  static DateTime parseMonthYear(String monthYear) {
    final parts = monthYear.split(' ');
    if (parts.length != 2) return DateTime.now();

    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final month = monthNames.indexWhere((m) => m == parts[0]) + 1;
    final year = int.tryParse(parts[1]) ?? DateTime.now().year;

    return DateTime(year, month);
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }
}
