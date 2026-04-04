import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat _dayMonthFormat = DateFormat('dd MMM');
final DateFormat _fullFormat = DateFormat('dd MMM yyyy');
final DateFormat _weekdayFormat = DateFormat('EEE');

String formatDayMonth(DateTime value) => _dayMonthFormat.format(value);

String formatFullDate(DateTime value) => _fullFormat.format(value);

String formatWeekday(DateTime value) => _weekdayFormat.format(value);

String daysTogetherLabel(DateTime startDate) {
  final today = DateTime.now();
  final difference = DateTime(
    today.year,
    today.month,
    today.day,
  ).difference(
    DateTime(startDate.year, startDate.month, startDate.day),
  );
  final total = difference.inDays + 1;
  return '$total days together';
}

Color colorFromHex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) {
    buffer.write('ff');
  }
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

double clampPercent(double value) {
  if (value < 0) {
    return 0;
  }
  if (value > 1) {
    return 1;
  }
  return value;
}
