part of 'reward_form_cubit.dart';

extension RewardFormLoad on BaseFormState {
	RewardFormDataLoadSuccess load({List<UICurrency> currencies, UIReward reward}) =>
			RewardFormDataLoadSuccess(currencies: currencies, reward: reward, formType: formType);
}

class RewardFormDataLoadSuccess extends BaseFormState {
	final List<UICurrency> currencies;
	final UIReward reward;
	final bool wasDataChanged;

	RewardFormDataLoadSuccess({this.currencies, this.reward, AppFormType formType, ObjectId rewardId, DataSubmissionState submissionState, this.wasDataChanged = false}) :
				super(formType: formType, loadingState: DataLoadingState.loadSuccess, submissionState: submissionState);

	RewardFormDataLoadSuccess copyWith({UIReward reward, DataSubmissionState submissionState}) => RewardFormDataLoadSuccess(
		currencies: currencies,
		reward: reward ?? this.reward,
		formType: formType,
		submissionState: submissionState ?? this.submissionState,
		wasDataChanged: wasDataChanged || this.reward != reward
	);

	@override
  StatefulState withSubmitState(DataSubmissionState submissionState) => copyWith(submissionState: submissionState);

  @override
	List<Object> get props => super.props..addAll([currencies, reward, wasDataChanged]);
}
