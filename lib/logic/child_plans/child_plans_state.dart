part of 'child_plans_cubit.dart';

abstract class ChildPlansState extends Equatable {
  const ChildPlansState();

  @override
  List<Object> get props => [];
}

class ChildPlansInitial extends ChildPlansState {}

class ChildPlansLoadInProgress extends ChildPlansState {}

class ChildPlansLoadSuccess extends ChildPlansState {
	final List<UIPlan> plans;
	final UIPlan activePlan;

  ChildPlansLoadSuccess({this.plans, this.activePlan});

  @override
	List<Object> get props => [plans, activePlan];

	@override
	String toString() {
		return 'ChildPlansLoadSuccess{plans: $plans, activePlan: $activePlan}';
	}
}
