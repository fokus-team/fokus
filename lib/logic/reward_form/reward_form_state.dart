part of 'reward_form_cubit.dart';

abstract class RewardFormState extends Equatable {
	final AppFormType formType;
	final ObjectId rewardId;

  const RewardFormState(this.formType, this.rewardId);

  @override
  List<Object> get props => [];
}

class RewardFormInitial extends RewardFormState {
  RewardFormInitial(AppFormType formType, [ObjectId rewardId]) : super(formType, rewardId);
}

class RewardFormDataLoadSuccess extends RewardFormState {
	final List<UICurrency> currencies;
	final RewardFormModel rewardForm;

	RewardFormDataLoadSuccess(RewardFormState current, this.currencies, [this.rewardForm]) : super(current.formType, current.rewardId);

	@override
	List<Object> get props => [currencies];
}

class RewardFormSubmissionInProgress extends RewardFormState {
	RewardFormSubmissionInProgress(RewardFormState current) : super(current.formType, current.rewardId);
}

class RewardFormSubmissionSuccess extends RewardFormState {
	RewardFormSubmissionSuccess(RewardFormState current) : super(current.formType, current.rewardId);
}
