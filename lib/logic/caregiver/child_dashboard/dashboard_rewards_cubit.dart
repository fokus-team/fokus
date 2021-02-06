import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';

class DashboardRewardsCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
	UIChild child;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	DashboardRewardsCubit(this._activeUser, ModalRoute pageRoute) : super(pageRoute, options: [ReloadableOption.noAutoLoading]);

	@override
	Future doLoadData() async {
		var rewardsAdded = await _dataRepository.countRewards(caregiverId: _activeUser().id);
		emit(DashboardRewardsState(childRewards: child.rewards, noRewardsAdded: rewardsAdded == 0));
	}

	@override
	List<NotificationType> dataTypeSubscription() => [NotificationType.rewardBought];
}

class DashboardRewardsState extends LoadableState {
	final List<UIReward> childRewards;
	final bool noRewardsAdded;

	DashboardRewardsState({this.childRewards, this.noRewardsAdded}) : super.loaded();

	@override
	List<Object> get props => super.props..addAll([childRewards, noRewardsAdded]);
}
