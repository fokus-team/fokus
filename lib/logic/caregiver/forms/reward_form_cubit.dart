import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' hide Action;
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import '../../../model/currency_type.dart';
import '../../../model/db/gamification/currency.dart';
import '../../../model/db/gamification/points.dart';
import '../../../model/db/gamification/reward.dart';
import '../../../model/db/user/caregiver.dart';
import '../../../model/ui/app_page.dart';
import '../../../services/analytics_service.dart';
import '../../../services/data/data_repository.dart';
import '../../common/cubit_base.dart';

class RewardFormCubit extends CubitBase<RewardFormData> {
	final ObjectId? _rewardId;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final AnalyticsService _analyticsService = GetIt.I<AnalyticsService>();
	
  RewardFormCubit(this._rewardId, ModalRoute pageRoute) : super(pageRoute);

  @override
	Future reload(_) => load(
	  initialData: RewardFormData(formType: _rewardId == null ? AppFormType.create : AppFormType.edit),
	  body: () async {
		  var user = activeUser as Caregiver;
		  var currencies = user.currencies!;
		  Reward reward;
		  if (state.data!.formType == AppFormType.create)
		    reward = Reward(cost: Points(icon: CurrencyType.diamond), limit: null);
		  else
		    reward = (await _dataRepository.getReward(id: _rewardId!))!;
			return Action.finish(state.data!.copyWith(currencies: currencies, reward: reward));
	  },
  );

  void onRewardChanged(Reward Function(Reward) function) {
  	if (!state.loaded)
  		return;
    emitData(state.data!.copyWith(reward: function(state.data!.reward!)));
  }
	
  Future submitRewardForm() => submit(body: () async {
	  var userId = activeUser!.id!;
	  var reward = state.data!.reward!.copyWith(createdBy: userId, id: state.data!.reward!.id);

	  if (state.data!.formType == AppFormType.create) {
		  await _dataRepository.createReward(reward);
		  _analyticsService.logRewardCreated(reward);
	  } else {
		  await _dataRepository.updateReward(reward);
	  }
  });
}

class RewardFormData extends Equatable {
	final List<Currency>? currencies;
	final Reward? reward;
	final bool wasDataChanged;
	final AppFormType formType;

	RewardFormData({this.currencies, this.reward, required this.formType, this.wasDataChanged = false});

	RewardFormData copyWith({Reward? reward, List<Currency>? currencies}) => RewardFormData(
			currencies: currencies ?? this.currencies,
			reward: reward ?? this.reward,
			formType: formType,
			wasDataChanged: wasDataChanged || this.reward != null && this.reward != reward
	);

	@override
	List<Object?> get props => [currencies, reward, wasDataChanged];
}
