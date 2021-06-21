import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../model/db/gamification/reward.dart';
import '../../../model/db/user/child.dart';
import '../../../model/notification/notification_type.dart';
import '../../../services/data/data_repository.dart';
import '../../common/cubit_base.dart';

class DashboardRewardsCubit extends CubitBase<DashboardRewardsData> {
	late Child child;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	DashboardRewardsCubit(ModalRoute pageRoute) : super(pageRoute, options: [StatefulOption.noAutoLoading]);

	@override
	Future reload(_) => load(body: () async {
		var rewardsAdded = await _dataRepository.countRewards(caregiverId: activeUser!.id!);
		return DashboardRewardsData(childRewards: child.rewards!, noRewardsAdded: rewardsAdded == 0);
	});

	@override
	List<NotificationType> notificationTypeSubscription() => [NotificationType.rewardBought];
}

class DashboardRewardsData extends Equatable {
	final List<Reward> childRewards;
	final bool noRewardsAdded;

	DashboardRewardsData({required this.childRewards, required this.noRewardsAdded});

	@override
	List<Object?> get props => [childRewards, noRewardsAdded];
}
