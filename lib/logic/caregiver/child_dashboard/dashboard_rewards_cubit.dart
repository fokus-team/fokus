import 'package:flutter/widgets.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/data/data_repository.dart';

class DashboardRewardsCubit extends StatefulCubit {
	late UIChild child;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	DashboardRewardsCubit(ModalRoute pageRoute) : super(pageRoute, options: [StatefulOption.noAutoLoading]);

	@override
	Future doLoadData() async {
		var rewardsAdded = await _dataRepository.countRewards(caregiverId: activeUser!.id!);
		emit(DashboardRewardsState(childRewards: child.rewards!, noRewardsAdded: rewardsAdded == 0));
	}

	@override
	List<NotificationType> notificationTypeSubscription() => [NotificationType.rewardBought];
}

class DashboardRewardsState extends StatefulState {
	final List<Reward> childRewards;
	final bool noRewardsAdded;

	DashboardRewardsState({required this.childRewards, required this.noRewardsAdded}) : super.loaded();

	@override
	List<Object?> get props => super.props..addAll([childRewards, noRewardsAdded]);
}
