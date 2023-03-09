extension DateTimeEx on DateTime {
  DateTime getStartOfMonth() {
    return DateTime(year, month, 1, 0, 0, 0);
  }

  DateTime getEndOfMonth() {
    final nextMonthFirstDay = DateTime(year, month + 1, 1, 0, 0, 0);
    return DateTime(nextMonthFirstDay.year, nextMonthFirstDay.month, nextMonthFirstDay.day - 1, 23, 59, 59);
  }
}
