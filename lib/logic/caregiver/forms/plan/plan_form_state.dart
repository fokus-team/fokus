part of 'plan_form_cubit.dart';

abstract class PlanFormState extends Equatable {
	final AppFormType formType;
	final ObjectId? planId;

  const PlanFormState(this.formType, this.planId);

  @override
  List<Object?> get props => [];
}

class PlanFormInitial extends PlanFormState {
  PlanFormInitial(AppFormType formType, [ObjectId? planId]) : super(formType, planId);
}

class PlanFormDataLoadSuccess extends PlanFormState {
	final List<UIChild> children;
	final List<Currency> currencies;
	final PlanFormModel? planForm;

	PlanFormDataLoadSuccess(PlanFormState current, this.children, this.currencies, [this.planForm]) : super(current.formType, current.planId);

	@override
	List<Object?> get props => [children, currencies];
}

class PlanFormSubmissionInProgress extends PlanFormState {
	PlanFormSubmissionInProgress(PlanFormState current) : super(current.formType, current.planId);
}

class PlanFormSubmissionSuccess extends PlanFormState {
	PlanFormSubmissionSuccess(PlanFormState current) : super(current.formType, current.planId);
}
