// @dart = 2.10
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';

import 'date/date_base.dart';

class DateSpan<D extends DateBase> {
  D from;
  D to;

  DateSpan({this.from, this.to});

  DateSpan.from(DateSpan<D> span) : this(
	  from: span.from != null ? copy(span.from) : null,
		to: span.to != null ? copy(span.to) : null
  );

  static D copy<D extends DateBase>(D date) => D == Date ? Date.fromDate(date) : TimeDate.fromDate(date);

  static DateSpan<D> fromJson<D extends DateBase>(Map<String, dynamic> json) {
  	var parseDate = (DateTime date) => D == Date ? Date.parseDBDate(date) : TimeDate.parseDBDate(date);
    return json != null ? DateSpan<D>(
      from: json['from'] != null ? parseDate(json['from']) : null,
      to: json['to'] != null ? parseDate(json['to']) : null,
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (from != null)
      data['from'] = this.from.toDBDate();
    if (to != null)
	    data['to'] = this.to.toDBDate();
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
	}[this];
}

