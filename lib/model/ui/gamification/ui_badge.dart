import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/gamification/badge.dart';

class UIBadge extends Equatable {
	final String name;
	final String description;
	final int icon;

	UIBadge({this.name, this.description, this.icon = 0});
	UIBadge.fromDBModel(Badge badge) : this(name: badge.name, description: badge.description, icon: badge.icon);

	UIBadge copyWith({String name, String description, int icon}) {
		return UIBadge(
			name: name ?? this.name,
			description: description ?? this.description,
			icon: icon ?? this.icon
		);
	}

  @override
  List<Object> get props => [name, description, icon];
}
