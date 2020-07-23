import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';

import 'date/date_base.dart';

class Duration<D extends DateBase> {
  D from;
  D to;

  Duration({this.from, this.to});

  factory Duration.fromJson(Map<String, dynamic> json) {
  	var parseDate = (String pattern) => D == Date ? Date.parseDBString(pattern) : TimeDate.parseDBString(pattern);
    return Duration(
      from: json['from'] != null ? parseDate(json['from']) : null,
      to: json['to'] != null ? parseDate(json['to']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from.toDBString();
    data['to'] = this.to.toDBString();
    return data;
  }
}
