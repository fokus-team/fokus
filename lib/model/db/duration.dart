import 'date/date_base.dart';

class Duration<D extends DateBase> {
  DateBase from;
  DateBase to;

  Duration({this.from, this.to});

  factory Duration.fromJson(Map<String, dynamic> json) {
    return Duration(
      from: json['from'] != null ? DateBase.parseDBString(json['from']) : null,
      to: json['to'] != null ? DateBase.parseDBString(json['to']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from'] = this.from.toDBString();
    data['to'] = this.to.toDBString();
    return data;
  }
}
