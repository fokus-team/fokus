import 'package:intl/intl.dart';

import 'date_base.dart';

class Date extends DateBase {
  static final DateFormat dbFormat = DateFormat("yyyy-MM-dd");

  Date(int year, int month, int day) : super(year, month, day);

  Date.fromDate(DateTime date) : super(date.year, date.month, date.day);

  Date.now() : this.fromDate(DateTime.now());

  factory Date.parseDBString(String date) => Date.fromDate(dbFormat.parseUtc(date));

  @override
  String toDBString() => dbFormat.format(this.toUtc());
}
