import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/model/pages/plan_form_params.dart';
import 'package:fokus/model/ui/form/reward_form_model.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/services/analytics_service.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'reward_form_state.dart';

class RewardFormCubit extends Cubit<RewardFormState> {
	final ActiveUserFunction _activeUser;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	
  RewardFormCubit(Object argument, this._activeUser) : super(RewardFormInitial(argument == null ? AppFormType.create : AppFormType.edit, argument));
  
	void loadFormData() async {
	  var user = _activeUser();
	  var rewardForm = state.formType == AppFormType.create ? RewardFormModel() : await _fillRewardFormModel();
		emit(RewardFormDataLoadSuccess(state, (user as UICaregiver).currencies, rewardForm));
  }
	
  void submitRewardForm(RewardFormModel rewardForm) async {
		emit(RewardFormSubmissionInProgress(state));
		var userId = _activeUser().id;
		var reward = Reward.fromRewardForm(rewardForm, userId, state.rewardId);

		if (state.formType == AppFormType.create) {
			await _dataRepository.createReward(reward);
			_analyticsService.logRewardCreated(reward);
		} else {
	    await _dataRepository.updateReward(reward);
		}
		emit(RewardFormSubmissionSuccess(state));
  }
	
  Future<RewardFormModel> _fillRewardFormModel() async {
		return RewardFormModel.fromDBModel(await _dataRepository.getReward(id: state.rewardId));
  }

}
