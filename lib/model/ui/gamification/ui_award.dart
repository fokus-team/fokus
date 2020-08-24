import 'package:equatable/equatable.dart';

import 'ui_points.dart';

class UIAward extends Equatable {
	final String name;
	final int limit;
	final UIPoints points;
	final int icon;

	UIAward({
		this.name,
		this.limit = 0,
		this.points,
		this.icon = 0
	});

	UIAward copyWith({String name, int limit, UIPoints points, int icon}) {
		return UIAward(
			name: name ?? this.name,
			limit: limit ?? this.limit,
			points: points ?? this.points,
			icon: icon ?? this.icon
		);
	}

  @override
  List<Object> get props => [name, limit, points, icon];
}
