part of 'caregiver_plans_cubit.dart';


abstract class CaregiverPlansState extends Equatable {
	const CaregiverPlansState();

	@override
	List<Object> get props => [];
}

class CaregiverPlansInitial extends CaregiverPlansState {}

class CaregiverPlansLoadInProgress extends CaregiverPlansState {}

class CaregiverPlansLoadSuccess extends CaregiverPlansState {
	final List<UIPlan> plans;


	CaregiverPlansLoadSuccess(this.plans);

	@override
	List<Object> get props => [plans];

	@override
	String toString() {
		return 'CaregiverPlansLoadSuccess{plans: $plans}';
	}
}
