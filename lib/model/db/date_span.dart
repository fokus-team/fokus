import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';

import 'date/date_base.dart';

class DateSpan<D extends DateBase> {
  D from;
  D to;

  DateSpan({this.from, this.to});

  static DateSpan<D> fromJson<D extends DateBase>(Map<String, dynamic> json) {
  	var parseDate = (DateTime date) => D == Date ? Date.parseDBDate(date) : TimeDate.parseDBDate(date);
    return json != null ? DateSpan<D>(
      from: json['from'] != null ? parseDate(json['from']) : null,
      to: json['to'] != null ? parseDate(json['to']) : null,
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from.toDBDate();
    data['to'] = this.to.toDBDate();
    return data;
  }
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

