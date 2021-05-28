import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/utils/definitions.dart';
import 'package:fokus/model/db/date/time_date.dart';

import 'date/date_base.dart';

class DateSpan<D extends DateBase> {
  D? from;
  D? to;

  DateSpan({this.from, this.to});

  DateSpan.from(DateSpan<D> span) : this(
	  from: span.from != null ? copy(span.from!) : null,
		to: span.to != null ? copy(span.to!) : null
  );

  static D copy<D extends DateBase>(D date) => (date is Date ? Date.fromDate(date) : TimeDate.fromDate(date)) as D;

  static DateSpan<D>? fromJson<D extends DateBase>(Json? json) {
  	var parseDate = (DateTime date) => (D == Date ? Date.parseDBDate(date) : TimeDate.parseDBDate(date)) as D;
    return json != null ? DateSpan<D>(
      from: json['from'] != null ? parseDate(json['from']) : null,
      to: json['to'] != null ? parseDate(json['to']) : null,
    ) : null;
  }

  Json toJson() {
    final Json data = new Json();
    if (from != null)
      data['from'] = from!.toDBDate();
    if (to != null)
	    data['to'] = to!.toDBDate();
    return data;
  }

  bool contains(D date, {bool includeFrom = true, bool includeTo = true}) {
  	return (date >= from && (includeFrom || date != from)) && (date <= to && (includeTo || date != to));
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is DateSpan && runtimeType == other.runtimeType && from == other.from && to == other.to;

  @override
  int get hashCode => from.hashCode ^ to.hashCode;
}

enum SpanDateType {
	start, end
}

extension SpanDateTypeField on SpanDateType {
	String get field => const {
		SpanDateType.start: 'from',
		SpanDateType.end: 'to'
	}[this]!;
}

