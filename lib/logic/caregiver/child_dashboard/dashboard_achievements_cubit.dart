import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/db/gamification/child_badge.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/analytics_service.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/notifications/notification_service.dart';

class DashboardAchievementsCubit extends StatefulCubit {
	final ActiveUserFunction _activeUser;
	UIChild child;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();

	DashboardAchievementsCubit(this._activeUser, ModalRoute pageRoute): super(pageRoute, options: [StatefulOption.noAutoLoading, StatefulOption.repeatableSubmission]);

	@override
	Future doLoadData() async {
		UICaregiver activeUser = _activeUser();
		var availableBadges = _filterBadges(activeUser.badges, child.badges);
		emit(DashboardAchievementsState(availableBadges: availableBadges, childBadges: child.badges));
	}

	Future assignBadges(List<UIBadge> badges) async {
		if (!beginSubmit())
			return;
		DashboardAchievementsState tabState = state;
		var assignedBadges = badges.map((badge) => UIChildBadge.fromBadge(badge)).toList();
		var childBadges = assignedBadges.map((badge) => ChildBadge.fromUIModel(badge)).toList();
		_dataRepository.updateUser(child.id, badges: childBadges);
		for (var badge in badges)
			_notificationService.sendBadgeAwardedNotification(badge.name, badge.icon, child.id);
		childBadges.forEach((badge) => _analyticsService.logBadgeAwarded(badge));

		var newAssignedBadges = List.of(tabState.childBadges)..addAll(assignedBadges);
		var newAvailableBadges = _filterBadges(tabState.availableBadges, assignedBadges);
		emit(tabState.copyWith(availableBadges: newAvailableBadges, childBadges: newAssignedBadges, submissionState: DataSubmissionState.submissionSuccess));
	}

	List<UIBadge> _filterBadges(List<UIBadge> list, List<UIChildBadge> excluded) => list.where((badge) => !excluded.any((exclude) => badge.sameAs(exclude))).toList();
}

class DashboardAchievementsState extends StatefulState {
	final List<UIBadge> availableBadges;
	final List<UIChildBadge> childBadges;

	DashboardAchievementsState({this.availableBadges, this.childBadges, DataSubmissionState submissionState}) : super.loaded(submissionState);

	DashboardAchievementsState copyWith({List<UIBadge> availableBadges, List<UIChildBadge> childBadges, DataSubmissionState submissionState}) {
		return DashboardAchievementsState(
			availableBadges: availableBadges ?? this.availableBadges,
			childBadges: childBadges ?? this.childBadges,
			submissionState: submissionState
		);
	}

	@override
	StatefulState withSubmitState(DataSubmissionState submissionState) => copyWith(submissionState: submissionState);

	@override
	List<Object> get props => super.props..addAll([availableBadges, childBadges]);
}
