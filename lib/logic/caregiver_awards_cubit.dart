import 'package:fokus/model/ui/gamification/ui_award.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';

class CaregiverAwardsCubit extends ReloadableCubit {
	final ActiveUserFunction _activeUser;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverAwardsCubit(this._activeUser, pageRoute) : super(pageRoute);

  @override
	doLoadData() async {
    var caregiverId = _activeUser().id;
    var awards = await _dataRepository.getAwards(caregiverId: caregiverId);
		emit(CaregiverAwardsLoadSuccess(awards.map((award) => UIAward.fromDBModel(award)).toList()));
  }
}

class CaregiverAwardsLoadSuccess extends DataLoadSuccess {
	final List<UIAward> awards;

	CaregiverAwardsLoadSuccess(this.awards);

	@override
	List<Object> get props => [awards];
}

