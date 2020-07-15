import 'date/date_base.dart';

class Duration<D extends DateBase> {
  DateBase from;
  DateBase to;

  Duration({this.from, this.to});

  factory Duration.fromJson(Map<String, dynamic> json) {
    return Duration(
      from: DateBase.parseDBString(json['from']),
      to: DateBase.parseDBString(json['to']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from.toDBString();
    data['to'] = this.to.toDBString();
    return data;
  }
}
