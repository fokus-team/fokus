part of 'plan_form_cubit.dart';

abstract class PlanFormState extends Equatable {
  const PlanFormState();

  @override
  List<Object> get props => [];
}

class PlanFormInitial extends PlanFormState {}

class PlanFormDataLoadSuccess extends PlanFormState {
	final List<UIChild> children;
	final List<UICurrency> currencies;

  PlanFormDataLoadSuccess(this.children, this.currencies);

	@override
  List<Object> get props => [children, currencies];
}

class PlanFormSubmissionInProgress extends PlanFormState {}

class PlanFormSubmissionSuccess extends PlanFormState {}
