import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/utils/definitions.dart';

import 'badge.dart';

class ChildBadge extends Badge {
  final TimeDate? date;

  ChildBadge({String? description, this.date, int? icon, String? name})
		  : super(description: description, name: name, icon: icon);
  ChildBadge.fromBadge(Badge badge, {TimeDate? date})
		  : this(name: badge.name, description: badge.description, icon: badge.icon, date: date ?? TimeDate.now());

  ChildBadge.fromJson(Json json) :
      date = TimeDate.parseDBDate(json['date']), super.fromJson(json);

  Json toJson() {
    final Json data = super.toJson();
    if (this.date != null)
      data['date'] = this.date!.toDBDate();
    return data;
  }

  @override
  List<Object?> get props => super.props..add(date);
}
