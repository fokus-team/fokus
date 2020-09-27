import 'package:fokus/model/db/date/time_date.dart';

class ChildBadge {
  String description;
  TimeDate date;
  int icon;
  String name;

  ChildBadge({this.description, this.date, this.icon, this.name});

  factory ChildBadge.fromJson(Map<String, dynamic> json) {
    return json != null ? ChildBadge(
      description: json['description'],
      date: TimeDate.parseDBDate(json['date']),
      icon: json['icon'],
      name: json['name'],
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['date'] = this.date.toDBDate();
    data['icon'] = this.icon;
    data['name'] = this.name;
    return data;
  }
}
