import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../model/db/plan/plan.dart';
import '../../services/data/data_repository.dart';
import '../common/stateful/stateful_cubit.dart';

class CaregiverPlansCubit extends StatefulCubit {
	final MapEntry<ObjectId, String>? _userID;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverPlansCubit(ModalRoute pageRoute, this._userID) : super(pageRoute);

  @override
	Future doLoadData() async {
    var caregiverId = _userID?.key ?? activeUser!.id;
    var plans = await _dataRepository.getPlans(caregiverId: caregiverId);
		emit(CaregiverPlansState(plans));
  }
}

class CaregiverPlansState extends StatefulState {
	final List<Plan> plans;

	CaregiverPlansState(this.plans) : super.loaded();

	@override
	List<Object?> get props => super.props..add(plans);
}
