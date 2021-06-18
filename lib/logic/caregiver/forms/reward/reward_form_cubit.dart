import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../../model/currency_type.dart';
import '../../../../model/db/gamification/currency.dart';
import '../../../../model/db/gamification/points.dart';
import '../../../../model/db/gamification/reward.dart';
import '../../../../model/db/user/caregiver.dart';
import '../../../../model/ui/app_page.dart';
import '../../../../services/analytics_service.dart';
import '../../../../services/data/data_repository.dart';
import '../../../common/stateful/stateful_cubit.dart';

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
	
  Future submitRewardForm() => submitData(body: () async {
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
  });
}
