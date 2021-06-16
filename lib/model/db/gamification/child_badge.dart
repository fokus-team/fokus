import '../../../utils/definitions.dart';
import '../date/time_date.dart';
import 'badge.dart';

class ChildBadge extends Badge {
  final TimeDate? date;

  ChildBadge({String? description, this.date, int? icon, String? name})
		  : super(description: description, name: name, icon: icon);
  ChildBadge.fromBadge(Badge badge, {TimeDate? date})
		  : this(name: badge.name, description: badge.description, icon: badge.icon, date: date ?? TimeDate.now());

  ChildBadge.fromJson(Json json) :
      date = TimeDate.parseDBDate(json['date']), super.fromJson(json);

  @override
  Json toJson() {
    final data = super.toJson();
    if (date != null)
      data['date'] = date!.toDBDate();
    return data;
  }

  @override
  List<Object?> get props => super.props..add(date);
}
