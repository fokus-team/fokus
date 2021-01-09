import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/db/gamification/child_badge.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/notification/notification_type.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/analytics_service.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/notifications/notification_service.dart';
import 'package:fokus/services/plan_keeper_service.dart';
import 'package:fokus/services/ui_data_aggregator.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'child_dashboard_state.dart';

class ChildDashboardCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
	final ObjectId childId;

	int _initialTab;
	List<Future Function()> _tabFunctions;
	List<Plan> _availablePlans;
	Child child;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	final PlanKeeperService _planKeeperService = GetIt.I<PlanKeeperService>();
	final NotificationService _notificationService = GetIt.I<NotificationService>();

  ChildDashboardCubit(Map<String, dynamic> args, this._activeUser, ModalRoute pageRoute) :
			_initialTab = args['tab'] ?? 0, childId = (args['child'] as UIChild).id, super(pageRoute) {
	  _tabFunctions = [_loadPlansTab, _loadRewardsTab, _loadAchievementsTab];
  }

  @override
  void doLoadData() async {
  	child = null;
	  await loadTab(_initialTab);
	  await loadTab((_initialTab + 1) % 3);
	  await loadTab((_initialTab + 2) % 3);
  }

  Future loadTab(int tabIndex) => _tabFunctions[tabIndex.clamp(0, 3)]();

  Future assignPlans(List<ObjectId> ids) async {
  	var tabState = (state as ChildDashboardState).plansTab;
  	var filterAssigned = (bool Function(UIPlan) condition) => tabState.availablePlans.where(condition).map((plan) => plan.id).toList();
	  var assignedIds = filterAssigned((plan) => ids.contains(plan.id) && !plan.assignedTo.contains(childId));
	  var unassignedIds = filterAssigned((plan) => !ids.contains(plan.id) && plan.assignedTo.contains(childId));
	  var assignedPlans = _availablePlans.where((plan) => assignedIds.contains(plan.id)).toList()..forEach((plan) => plan.assignedTo.add(childId));
		await Future.wait([
			_dataRepository.updatePlanFields(assignedIds, assign: childId),
		  _dataRepository.updatePlanFields(unassignedIds, unassign: childId),
	    _planKeeperService.createPlansForToday(assignedPlans, [childId])
	  ]);
		var updateAssigned = (UIPlan plan) {
			var assignedTo = List.of(plan.assignedTo);
			if (assignedIds.contains(plan.id))
				assignedTo.add(childId);
			else if (unassignedIds.contains(plan.id))
				assignedTo.remove(childId);
			return assignedTo;
	  };
		var newPlans = tabState.availablePlans.map((plan) => plan.copyWith(assignedTo: updateAssigned(plan))).toList();
		var newChildPlans = List.of(tabState.childPlans)..addAll(await _dataAggregator.loadPlanInstances(childId: childId, plans: assignedPlans));
		emit(ChildDashboardState.from(state, plansTab: tabState.copyWith(availablePlans: newPlans, childPlans: newChildPlans)));
  }

	Future onNameDialogClosed(Future result) async {
  	var value = await result;
		if (value == null)
			return;
		child.name = value as String;
		emit(ChildDashboardState.from(state, child: UIChild.from((state  as ChildDashboardState).child, name: value as String)));
	}

	@override
  List<NotificationType> dataTypeSubscription() => [NotificationType.rewardBought];

  Future _loadPlansTab() async {
		var activeUser = _activeUser();
		var planInstances = (await _dataRepository.getPlanInstances(childIDs: [childId], fields: ['_id'])).map((plan) => plan.id).toList();
  	var data = await Future.wait([
		  _dataAggregator.loadPlanInstances(childId: childId),
		  _dataRepository.countTaskInstances(planInstancesId: planInstances, isCompleted: true, state: TaskState.notEvaluated),
		  _dataRepository.countPlans(caregiverId: activeUser.id),
		  _dataRepository.getPlans(caregiverId: activeUser.id),
	  ]);
  	_availablePlans = data[3];
  	var availablePlans = _availablePlans.map((plan) => UIPlan.fromDBModel(plan)).toList();
  	var tabState = ChildDashboardPlansTabState(childPlans: data[0], availablePlans: availablePlans, unratedTasks: (data[1] as int) > 0, noPlansAdded: (data[2] as int) == 0);
		emit(ChildDashboardState.from(_getPreviousState(), plansTab: tabState, child: await _loadChildProfile()));
	}

	Future _loadRewardsTab() async {
		child ??= await _dataRepository.getUser(id: childId, fields: ['rewards', 'badges']);
		var rewards = child.rewards.map((reward) => UIChildReward.fromDBModel(reward)).toList();
  	var tabState = ChildDashboardRewardsTabState(childRewards: rewards, noRewardsAdded: await _dataRepository.countRewards(caregiverId: _activeUser().id) == 0);
		emit(ChildDashboardState.from(_getPreviousState(), rewardsTab: tabState, child: await _loadChildProfile()));
	}

	List<UIBadge> filterBadges(List<UIBadge> list, List<UIChildBadge> excluded) => list.where((badge) => !excluded.any((exclude) => badge.sameAs(exclude))).toList();

	Future assignBadges(List<UIBadge> badges) async {
		var badgeTab = (state as ChildDashboardState).achievementsTab;
		var assignedBadges = badges.map((badge) => UIChildBadge.fromBadge(badge)).toList();
		var childBadges = assignedBadges.map((badge) => ChildBadge.fromUIModel(badge)).toList();
		_dataRepository.updateUser(childId, badges: childBadges);
		for (var badge in badges)
			_notificationService.sendBadgeAwardedNotification(badge.name, badge.icon, childId);
		childBadges.forEach((badge) => _analyticsService.logBadgeAwarded(badge));

		var newAssignedBadges = List.of(badgeTab.childBadges)..addAll(assignedBadges);
		var newAvailableBadges = filterBadges(badgeTab.availableBadges, assignedBadges);
		emit(ChildDashboardState.from(state, achievementsTab: badgeTab.copyWith(availableBadges: newAvailableBadges, childBadges: newAssignedBadges)));
	}

	Future _loadAchievementsTab() async {
		UICaregiver activeUser = _activeUser();
		child ??= await _dataRepository.getUser(id: childId);
		var assignedBadges = child.badges.map((badge) => UIChildBadge.fromDBModel(badge)).toList();
		var availableBadges = filterBadges(activeUser.badges, assignedBadges);
		var tabState = ChildDashboardAchievementsTabState(availableBadges: availableBadges, childBadges: assignedBadges);
		emit(ChildDashboardState.from(_getPreviousState(), achievementsTab: tabState, child: await _loadChildProfile()));
	}

	Future<UIChild> _loadChildProfile() => state is ChildDashboardState ? null : _dataAggregator.loadChild(childId);
	ChildDashboardState _getPreviousState() => state is ChildDashboardState ? state : null;
}
