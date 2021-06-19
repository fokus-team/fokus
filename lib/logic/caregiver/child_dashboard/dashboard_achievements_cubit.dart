import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../../model/db/gamification/badge.dart';
import '../../../model/db/gamification/child_badge.dart';
import '../../../model/db/user/caregiver.dart';
import '../../../model/db/user/child.dart';
import '../../../services/analytics_service.dart';
import '../../../services/data/data_repository.dart';
import '../../../services/notifications/notification_service.dart';
import '../../common/cubit_base.dart';

class DashboardAchievementsCubit extends CubitBase<DashboardAchievementsData> {
	late Child child;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();

	DashboardAchievementsCubit(ModalRoute pageRoute): super(pageRoute, options: [StatefulOption.noAutoLoading, StatefulOption.resetSubmissionState]);

	@override
	Future loadData() => load(body: () async {
		var user = activeUser as Caregiver;
		var availableBadges = _filterBadges(user.badges!, child.badges!);
		return DashboardAchievementsData(availableBadges: availableBadges, childBadges: child.badges!);
	});

	Future assignBadges(List<Badge> badges) => submit(body: () async {
		var assignedBadges = badges.map((badge) => ChildBadge.fromBadge(badge)).toList();
		_dataRepository.updateUser(child.id!, badges: assignedBadges);
		for (var badge in badges)
			_notificationService.sendBadgeAwardedNotification(badge.name!, badge.icon!, child.id!);
		assignedBadges.forEach(_analyticsService.logBadgeAwarded);

		var newAssignedBadges = List.of(state.data!.childBadges)..addAll(assignedBadges);
		var newAvailableBadges = _filterBadges(state.data!.availableBadges, assignedBadges);
		return state.data!.copyWith(availableBadges: newAvailableBadges, childBadges: newAssignedBadges);
	});

	List<Badge> _filterBadges(List<Badge> list, List<ChildBadge> excluded) => list.where((badge) => !excluded.any((exclude) => badge == exclude)).toList();
}

class DashboardAchievementsData extends Equatable {
	final List<Badge> availableBadges;
	final List<ChildBadge> childBadges;

	DashboardAchievementsData({required this.availableBadges, required this.childBadges});

	DashboardAchievementsData copyWith({List<Badge>? availableBadges, List<ChildBadge>? childBadges}) {
		return DashboardAchievementsData(
			availableBadges: availableBadges ?? this.availableBadges,
			childBadges: childBadges ?? this.childBadges,
		);
	}

	@override
	List<Object?> get props => [availableBadges, childBadges];
}
