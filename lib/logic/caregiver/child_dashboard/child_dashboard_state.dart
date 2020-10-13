part of 'child_dashboard_cubit.dart';

class ChildDashboardState extends DataLoadSuccess {
	final UIChild child;

	final ChildDashboardPlansTabState plansTab;
	final ChildDashboardRewardsTabState rewardsTab;
	final ChildDashboardAchievementsTabState achievementsTab;

	ChildDashboardState({this.child, this.plansTab, this.rewardsTab, this.achievementsTab});
	ChildDashboardState copyWith({UIChild child, ChildDashboardPlansTabState plansTab,
			ChildDashboardRewardsTabState rewardsTab, ChildDashboardAchievementsTabState achievementsTab}) {
		return ChildDashboardState(
			child: child ?? this.child,
			plansTab: plansTab ?? this.plansTab,
			rewardsTab: rewardsTab ?? this.rewardsTab,
			achievementsTab: achievementsTab ?? this.achievementsTab,
		);
	}

	@override
	List<Object> get props => [plansTab, rewardsTab, achievementsTab];
}

class ChildDashboardPlansTabState extends Equatable {
	final List<UIPlanInstance> plans;

	ChildDashboardPlansTabState(this.plans);

	@override
	List<Object> get props => [plans];
}

class ChildDashboardRewardsTabState extends Equatable {
	ChildDashboardRewardsTabState();

	@override
	List<Object> get props => [];
}

class ChildDashboardAchievementsTabState extends Equatable {
	ChildDashboardAchievementsTabState();

	@override
	List<Object> get props => [];
}
