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
    if (this.description != null)
      data['description'] = this.description;
    if (this.date != null)
      data['date'] = this.date.toDBDate();
    if (this.icon != null)
      data['icon'] = this.icon;
    if (this.name != null)
      data['name'] = this.name;
    return data;
  }
}
