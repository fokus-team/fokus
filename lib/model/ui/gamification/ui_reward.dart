import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'ui_points.dart';

class UIReward extends Equatable {
	final ObjectId id;
	final String name;
	final int limit;
	final UIPoints cost;
	final int icon;

	UIReward({this.id, this.name, this.limit = 0, this.cost, this.icon = 0});
	UIReward.fromDBModel(Reward reward) : this(id: reward.id, name: reward.name, limit: reward.limit, icon: reward.icon,
			cost: reward.cost != null ? UIPoints(type: reward.cost.icon, title: reward.cost.name, quantity: reward.cost.quantity, createdBy: reward.cost.createdBy) : null);

	UIReward copyWith({String name, int limit, UIPoints cost, int icon}) {
		return UIReward(
			name: name ?? this.name,
			limit: limit ?? this.limit,
			cost: cost ?? this.cost,
			icon: icon ?? this.icon
		);
	}

  @override
  List<Object> get props => [id, name, limit, cost, icon];
}
