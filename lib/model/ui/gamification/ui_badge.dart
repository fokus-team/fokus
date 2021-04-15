import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/gamification/child_badge.dart';

class UIBadge extends Equatable {
	final String name;
	final String description;
	final int icon;

	UIBadge({required this.name, required this.description, this.icon = 0});
	UIBadge.from(UIBadge badge) : this(name: badge.name, description: badge.description, icon: badge.icon);
	UIBadge.fromDBModel(Badge badge) : this(name: badge.name!, description: badge.description!, icon: badge.icon!);

	UIBadge copyWith({String? name, String? description, int? icon}) {
		return UIBadge(
			name: name ?? this.name,
			description: description ?? this.description,
			icon: icon ?? this.icon
		);
	}

	bool sameAs(UIBadge badge) => name == badge.name && description == badge.description && icon == badge.icon;

  @override
  List<Object> get props => [name, description, icon];
}

class UIChildBadge extends UIBadge {
	final TimeDate date;

	UIChildBadge({required String name, required String description, required int icon, required this.date})
			: super(name: name, description: description, icon: icon);
	UIChildBadge.fromDBModel(ChildBadge badge)
			: this(name: badge.name!, description: badge.description!, icon: badge.icon!, date: badge.date!);
	UIChildBadge.fromBadge(UIBadge badge, {TimeDate? date})
			: this(name: badge.name, description: badge.description, icon: badge.icon, date: date ?? TimeDate.now());
	
	UIChildBadge copyWith({String? name, String? description, int? icon, TimeDate? date}) {
		return UIChildBadge(
			name: name ?? this.name,
			description: description ?? this.description,
			icon: icon ?? this.icon,
			date: date ?? this.date
		);
	}

  @override
  List<Object> get props => super.props..addAll([date]);
}
