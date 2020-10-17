part of 'child_dashboard_cubit.dart';

class ChildDashboardState extends DataLoadSuccess {
	final UIChild child;

	final ChildDashboardPlansTabState plansTab;
	final ChildDashboardRewardsTabState rewardsTab;
	final ChildDashboardAchievementsTabState achievementsTab;

	ChildDashboardState({this.child, this.plansTab, this.rewardsTab, this.achievementsTab});
	ChildDashboardState.from(ChildDashboardState original, {UIChild child, ChildDashboardPlansTabState plansTab,
			ChildDashboardRewardsTabState rewardsTab, ChildDashboardAchievementsTabState achievementsTab}) :
			child = child ?? original?.child,
			plansTab = plansTab ?? original?.plansTab,
			rewardsTab = rewardsTab ?? original?.rewardsTab,
			achievementsTab = achievementsTab ?? original?.achievementsTab;

	@override
	List<Object> get props => [child, plansTab, rewardsTab, achievementsTab];
}

class ChildDashboardPlansTabState extends Equatable {
	final List<UIPlanInstance> childPlans;
	final List<UIPlan> availablePlans;
	final bool noPlansAdded;
	final bool unratedTasks;

	ChildDashboardPlansTabState({this.childPlans, this.availablePlans, this.noPlansAdded, this.unratedTasks});

	ChildDashboardPlansTabState copyWith({List<UIPlan> availablePlans, List<UIPlanInstance> childPlans}) {
		return ChildDashboardPlansTabState(
			childPlans: childPlans ?? this.childPlans,
			availablePlans: availablePlans ?? this.availablePlans,
			noPlansAdded: noPlansAdded,
			unratedTasks: unratedTasks
		);
	}

	@override
	List<Object> get props => [childPlans, availablePlans, noPlansAdded, unratedTasks];
}

class ChildDashboardRewardsTabState extends Equatable {
	final List<UIReward> childRewards;
	final bool noRewardsAdded;

	ChildDashboardRewardsTabState({this.childRewards, this.noRewardsAdded});

	@override
	List<Object> get props => [childRewards, noRewardsAdded];
}

class ChildDashboardAchievementsTabState extends Equatable {
	final List<UIBadge> availableBadges;
	final List<UIChildBadge> childBadges;

	ChildDashboardAchievementsTabState({this.availableBadges, this.childBadges});

	ChildDashboardAchievementsTabState copyWith({List<UIBadge> availableBadges, List<UIChildBadge> childBadges}) {
		return ChildDashboardAchievementsTabState(
			availableBadges: availableBadges ?? this.availableBadges,
			childBadges: childBadges ?? this.childBadges,
		);
	}

	@override
	List<Object> get props => [availableBadges, childBadges];
}
