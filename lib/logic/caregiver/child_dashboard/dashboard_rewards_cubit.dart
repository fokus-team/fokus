import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../model/db/gamification/reward.dart';
import '../../../model/db/user/child.dart';
import '../../../model/notification/notification_type.dart';
import '../../../services/data/data_repository.dart';
import '../../common/stateful/stateful_cubit.dart';

class DashboardRewardsCubit extends StatefulCubit<DashboardRewardsData> {
	late Child child;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	DashboardRewardsCubit(ModalRoute pageRoute) : super(pageRoute, options: [StatefulOption.noAutoLoading]);

	@override
	Future load() => doLoad(body: () async {
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
