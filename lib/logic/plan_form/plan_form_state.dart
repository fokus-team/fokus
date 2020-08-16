part of 'plan_form_cubit.dart';

abstract class PlanFormState extends Equatable {
  const PlanFormState();

  @override
  List<Object> get props => [];
}

class PlanFormInitial extends PlanFormState {}

class PlanFormSubmissionInProgress extends PlanFormState {}

class PlanFormSubmissionSuccess extends PlanFormState {}
