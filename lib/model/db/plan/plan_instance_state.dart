enum PlanInstanceState {
	notStarted, active, completed, notCompleted, lostForever // Do you really want to live forever?
}

extension PlanInstanceStateGroups on PlanInstanceState {
	bool get inProgress => this == PlanInstanceState.active || this == PlanInstanceState.notCompleted;
	bool get ended => this == PlanInstanceState.completed || this == PlanInstanceState.lostForever;
}
