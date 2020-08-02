import 'date_base.dart';

class TimeDate extends DateBase {
  TimeDate(int year, int month, int day, [int hour = 0, int minute = 0, int second = 0]) : super(year, month, day, hour, minute, second);

  TimeDate.fromDate(DateTime date) : super(date.year, date.month, date.day, date.hour, date.day, date.second);

  TimeDate.now() : this.fromDate(DateTime.now());

  factory TimeDate.parseDBDate(DateTime date) => date != null ? TimeDate.fromDate(date.toLocal()) : null;

  @override
  DateTime toDBDate() => this.toUtc();

  @override
  bool operator ==(dynamic other) => super==(other) && hour == other.hour && minute == other.minute && second == other.second;
  @override
  int get hashCode => combine(combine(combine(super.hashCode, hour.hashCode), minute.hashCode), second.hashCode);

  bool operator >=(DateBase other) => super>=(other) && hour >= other.hour && minute >= other.minute && second >= other.second;
  bool operator <=(DateBase other) => super>=(other) && hour <= other.hour && minute <= other.minute && second <= other.second;
}
