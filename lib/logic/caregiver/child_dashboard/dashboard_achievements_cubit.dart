import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/db/gamification/child_badge.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/db/gamification/badge.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/services/analytics_service.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/notifications/notification_service.dart';

class DashboardAchievementsCubit extends StatefulCubit {
	late Child child;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();

	DashboardAchievementsCubit(ModalRoute pageRoute): super(pageRoute, options: [StatefulOption.noAutoLoading, StatefulOption.resetSubmissionState]);

	@override
	Future doLoadData() async {
		var user = activeUser as Caregiver;
		var availableBadges = _filterBadges(user.badges!, child.badges!);
		emit(DashboardAchievementsState(availableBadges: availableBadges, childBadges: child.badges!));
	}

	Future assignBadges(List<Badge> badges) async {
		if (!beginSubmit())
			return;
		var tabState = state as DashboardAchievementsState;
		var assignedBadges = badges.map((badge) => ChildBadge.fromBadge(badge)).toList();
		_dataRepository.updateUser(child.id!, badges: assignedBadges);
		for (var badge in badges)
			_notificationService.sendBadgeAwardedNotification(badge.name!, badge.icon!, child.id!);
		assignedBadges.forEach((badge) => _analyticsService.logBadgeAwarded(badge));

		var newAssignedBadges = List.of(tabState.childBadges)..addAll(assignedBadges);
		var newAvailableBadges = _filterBadges(tabState.availableBadges, assignedBadges);
		emit(tabState.copyWith(availableBadges: newAvailableBadges, childBadges: newAssignedBadges, submissionState: DataSubmissionState.submissionSuccess));
	}

	List<Badge> _filterBadges(List<Badge> list, List<ChildBadge> excluded) => list.where((badge) => !excluded.any((exclude) => badge == exclude)).toList();
}

class DashboardAchievementsState extends StatefulState {
	final List<Badge> availableBadges;
	final List<ChildBadge> childBadges;

	DashboardAchievementsState({required this.availableBadges, required this.childBadges, DataSubmissionState? submissionState}) : super.loaded(submissionState);

	DashboardAchievementsState copyWith({List<Badge>? availableBadges, List<ChildBadge>? childBadges, DataSubmissionState? submissionState}) {
		return DashboardAchievementsState(
			availableBadges: availableBadges ?? this.availableBadges,
			childBadges: childBadges ?? this.childBadges,
			submissionState: submissionState
		);
	}

	@override
	StatefulState withSubmitState(DataSubmissionState submissionState) => copyWith(submissionState: submissionState);

	@override
	List<Object?> get props => super.props..addAll([availableBadges, childBadges]);
}
