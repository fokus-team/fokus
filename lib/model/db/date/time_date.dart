import 'date_base.dart';

class TimeDate extends DateBase {
  TimeDate(int year, int month, int day, [int hour = 0, int minute = 0, int second = 0]) : super(year, month, day, hour, minute, second);

  TimeDate.fromDate(DateTime date) : super(date.year, date.month, date.day, date.hour, date.minute, date.second);

  TimeDate.now() : this.fromDate(DateTime.now());

  static TimeDate? parseDBDate(DateTime? date) => date != null ? TimeDate.fromDate(date.toLocal()) : null;

  @override
  DateTime toDBDate() => toUtc();

  @override
  bool operator ==(dynamic other) => identical(this, other) || other is TimeDate &&
		  super==(other) && hour == other.hour && minute == other.minute && second == other.second;
  @override
  int get hashCode => combine(combine(combine(super.hashCode, hour.hashCode), minute.hashCode), second.hashCode);

  @override
  bool operator >(DateBase? other) => super>=(other) && (hour > other!.hour || (hour == other.hour && (minute > other.minute || (minute == other.minute && second > other.second))));
  @override
  bool operator <(DateBase? other) => super>=(other) && (hour < other!.hour || (hour == other.hour && (minute < other.minute || (minute == other.minute && second < other.second))));
}
