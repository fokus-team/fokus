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

  ChildPlansLoadSuccess(this.plans);

  @override
	List<Object> get props => [plans];

	@override
	String toString() {
		return 'ChildPlansLoadSuccess{plans: $plans}';
	}
}
