import 'date_base.dart';

class Date extends DateBase {
  Date(int year, int month, int day) : super(year, month, day);

  Date.fromDate(DateTime date) : super(date.year, date.month, date.day);

  Date.now() : this.fromDate(DateTime.now());

  factory Date.parseDBDate(DateTime date) => Date.fromDate(date);

  @override
  DateTime toDBDate() => this;
}
