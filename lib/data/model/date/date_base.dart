import 'package:fokus/data/model/date/time_date.dart';
import 'package:intl/intl.dart';

import 'date.dart';

abstract class DateBase extends DateTime {
  DateBase(int year, int month, int day, [int hour = 0, int minute = 0, int second = 0]) : super(year, month, day, hour, minute, second);

  factory DateBase.parseDBString(String date) {
    if (Date.dbFormat.digitMatcher.hasMatch(date)) return Date.parseDBString(date);
    if (TimeDate.dbFormat.digitMatcher.hasMatch(date)) return TimeDate.parseDBString(date);
    print("Pattern $date does not match any of the supported date types");
    return null;
  }

  String toDBString();

  String toAppString(DateFormat format) => format.format(this.toLocal());
}
