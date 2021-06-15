import 'package:equatable/equatable.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/utils/definitions.dart';
import 'package:fokus/model/db/date/time_date.dart';

import 'date/date_base.dart';

class DateSpan<D extends DateBase> extends Equatable {
  final D? from;
  final D? to;

  DateSpan({this.from, this.to});

  DateSpan.from(DateSpan<D> span) : this(
	  from: span.from != null ? _copy(span.from!) : null,
		to: span.to != null ? _copy(span.to!) : null
  );

  DateSpan<D> copyWith({D? from, D? to}) => DateSpan(from: from ?? this.from, to: to ?? this.to);
  DateSpan<D> end() => copyWith(to: (from is Date ? Date.now() : TimeDate.now()) as D);

  static D _copy<D extends DateBase>(D date) => (date is Date ? Date.fromDate(date) : TimeDate.fromDate(date)) as D;

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
  List<Object?> get props => [from, to];
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

