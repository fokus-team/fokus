import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/services/analytics_service.dart';

part 'reward_form_state.dart';

class RewardFormCubit extends StatefulCubit<BaseFormState> {
	final ActiveUserFunction _activeUser;
	final ObjectId _rewardId;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	
  RewardFormCubit(this._rewardId, this._activeUser, ModalRoute pageRoute) :
			  super(pageRoute, initialState: BaseFormState(formType: _rewardId == null ? AppFormType.create : AppFormType.edit));

  @override
	Future doLoadData() async {
	  var user = _activeUser();
	  var currencies = (user as UICaregiver).currencies;
	  UIReward reward;
	  if (state.formType == AppFormType.create)
	    reward = UIReward(cost: UIPoints.fromUICurrency(currencies.firstWhere((currency) => currency.type == CurrencyType.diamond)), limit: null);
	  else
	    reward = UIReward.fromDBModel(await _dataRepository.getReward(id: _rewardId));
		emit(state.load(currencies: currencies, reward: reward));
  }

  void onRewardChanged(UIReward Function(UIReward) update) {
  	if (!this.state.loaded)
  		return;
	  RewardFormDataLoadSuccess state = this.state;
    emit(state.copyWith(reward: update(state.reward)));
  }
	
  void submitRewardForm() async {
		if (!beginSubmit())
			return;

		var userId = _activeUser().id;
		RewardFormDataLoadSuccess state = this.state;
		var reward = Reward.fromUIModel(state.reward, userId, state.reward.id);

		if (state.formType == AppFormType.create) {
			await _dataRepository.createReward(reward);
			_analyticsService.logRewardCreated(reward);
		} else {
	    await _dataRepository.updateReward(reward);
		}
		emit(state.submissionSuccess());
  }
}
