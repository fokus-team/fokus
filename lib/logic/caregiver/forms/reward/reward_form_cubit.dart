import 'package:flutter/widgets.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/db/gamification/reward.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/services/analytics_service.dart';

part 'reward_form_state.dart';

class RewardFormCubit extends StatefulCubit<BaseFormState> {
	final ObjectId? _rewardId;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	
  RewardFormCubit(this._rewardId, ModalRoute pageRoute) :
			  super(pageRoute, initialState: BaseFormState(formType: _rewardId == null ? AppFormType.create : AppFormType.edit));

  @override
	Future doLoadData() async {
	  var user = activeUser as Caregiver;
	  var currencies = user.currencies!;
	  Reward reward;
	  if (state.formType == AppFormType.create)
	    reward = Reward(cost: Points(icon: CurrencyType.diamond), limit: null);
	  else
	    reward = (await _dataRepository.getReward(id: _rewardId!))!;
		emit(state.load(currencies: currencies, reward: reward));
  }

  void onRewardChanged(Reward Function(Reward) update) {
  	if (!this.state.loaded)
  		return;
	  var state = this.state as RewardFormDataLoadSuccess;
    emit(state.copyWith(reward: update(state.reward)));
  }
	
  void submitRewardForm() async {
		if (!beginSubmit())
			return;

		var userId = activeUser!.id!;
		var state = this.state as RewardFormDataLoadSuccess;
		var reward = state.reward.copyWith(createdBy: userId, id: state.reward.id);

		if (state.formType == AppFormType.create) {
			await _dataRepository.createReward(reward);
			_analyticsService.logRewardCreated(reward);
		} else {
	    await _dataRepository.updateReward(reward);
		}
		emit(state.submissionSuccess() as BaseFormState);
  }
}
