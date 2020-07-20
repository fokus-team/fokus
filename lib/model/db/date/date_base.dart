import 'package:intl/intl.dart';

import 'package:fokus/model/db/date/time_date.dart';
import 'package:meta/meta.dart';

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

  @override
  bool operator ==(dynamic other) => other is DateTime && year == other.year && month == other.month && day == other.day;
  @override
  int get hashCode => combine(combine(combine(0, year.hashCode), month.hashCode), day.hashCode);

  bool operator >(DateBase other) => other != null && this >= other && this != other;
  bool operator >=(DateBase other) => other != null && year >= other.year && month >= other.month && day >= other.day;
  bool operator <(DateBase other) => other != null && this <= other && this != other;
  bool operator <=(DateBase other) => other != null && year <= other.year && month <= other.month && day <= other.day;

  @protected
  int combine(int hash, int value) {
	  hash = 0x1fffffff & (hash + value);
	  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
	  return hash ^ (hash >> 6);
  }
}
