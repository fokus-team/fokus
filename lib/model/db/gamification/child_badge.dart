// @dart = 2.10
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';

import 'badge.dart';

class ChildBadge extends Badge {
  TimeDate date;

  ChildBadge({String description, this.date, int icon, String name}) : super(description: description, name: name, icon: icon);
  ChildBadge.fromUIModel(UIChildBadge badge) : this(name: badge.name, description: badge.description, icon: badge.icon, date: badge.date);

  factory ChildBadge.fromJson(Map<String, dynamic> json) {
    return json != null ? ChildBadge(
      description: json['description'],
      date: TimeDate.parseDBDate(json['date']),
      icon: json['icon'],
      name: json['name'],
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.date != null)
      data['date'] = this.date.toDBDate();
    return data;
  }
}
