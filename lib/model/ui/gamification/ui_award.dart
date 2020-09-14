import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/gamification/reward.dart';

import 'ui_points.dart';

class UIAward extends Equatable {
	final String name;
	final int limit;
	final UIPoints cost;
	final int icon;

	UIAward({
		this.name,
		this.limit = 0,
		this.cost,
		this.icon = 0
	});
	UIAward.fromDBModel(Reward reward) : this(name: reward.name, limit: reward.limit, cost: reward.cost != null ? UIPoints(quantity: reward.cost.quantity, type: reward.cost.icon, title: reward.cost.name) : null, icon: reward.icon);

	UIAward copyWith({String name, int limit, UIPoints cost, int icon}) {
		return UIAward(
			name: name ?? this.name,
			limit: limit ?? this.limit,
			cost: cost ?? this.cost,
			icon: icon ?? this.icon
		);
	}

  @override
  List<Object> get props => [name, limit, cost, icon];
}
