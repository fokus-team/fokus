import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/utils/definitions.dart';

import 'badge.dart';

class ChildBadge extends Badge {
  TimeDate? date;

  ChildBadge({String? description, this.date, int? icon, String? name})
		  : super(description: description, name: name, icon: icon);
  ChildBadge.fromUIModel(UIChildBadge badge)
		  : this(name: badge.name, description: badge.description, icon: badge.icon, date: badge.date);

  static ChildBadge? fromJson(Json? json) {
    return json != null ? (ChildBadge(
      date: TimeDate.parseDBDate(json['date']),
    )..assignFromJson(json)) : null;
  }

  Json toJson() {
    final Json data = super.toJson();
    if (this.date != null)
      data['date'] = this.date!.toDBDate();
    return data;
  }
}
