import 'date_base.dart';

class Date extends DateBase {
  Date(int year, int month, int day) : super.utc(year, month, day);

  Date.fromDate(DateTime date) : super.utc(date.year, date.month, date.day);

  Date.now() : this.fromDate(DateTime.now());

  factory Date.parseDBDate(DateTime date) => date != null ? Date.fromDate(date) : null;

  @override
  DateTime toDBDate() => this;
}
