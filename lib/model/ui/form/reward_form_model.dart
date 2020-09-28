import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';

// ignore: must_be_immutable
class RewardFormModel extends Equatable {
	String name;
	int limit;
	int pointValue;
	UICurrency pointCurrency;
	int icon = 0;

	RewardFormModel();
	RewardFormModel.fromDBModel(Reward reward) : name = reward.name, limit = reward.limit, icon = reward.icon,
			pointValue = reward.cost != null ? reward.cost.quantity : null,
			pointCurrency = reward.cost != null ? UICurrency(type: reward.cost.icon, title: reward.cost.name): null;
	RewardFormModel.from(RewardFormModel model) : name = model.name, limit = model.limit, icon = model.icon,
			pointValue = model.pointValue, pointCurrency = model.pointCurrency;

	@override
	List<Object> get props => [name, limit, pointValue, pointCurrency, icon];
}
