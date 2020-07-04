import 'package:fokus/data/model/date/date_base.dart';
import 'package:intl/intl.dart';

class TimeDate extends DateBase {
  static final DateFormat dbFormat = DateFormat("yyyy-MM-dd hh:mm:ss");

  TimeDate(int year, int month, int day, [int hour = 0, int minute = 0, int second = 0]) : super(year, month, day, hour, minute, second);

  TimeDate.fromDate(DateTime date) : super(date.year, date.month, date.day, date.hour, date.day, date.second);

  TimeDate.now() : this.fromDate(DateTime.now());

  factory TimeDate.parseDBString(String date) => dbFormat.parseUtc(date);

  @override
  String toDBString() => dbFormat.format(this.toUtc());
}
