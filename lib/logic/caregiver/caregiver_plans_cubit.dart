import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../model/db/plan/plan.dart';
import '../../services/data/data_repository.dart';
import '../common/cubit_base.dart';

class CaregiverPlansCubit extends CubitBase<CaregiverPlansData> {
	final MapEntry<ObjectId, String>? _userID;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverPlansCubit(ModalRoute pageRoute, this._userID) : super(pageRoute);

  @override
	Future loadData() => load(body: () async {
	  if (activeUser == null) return null;
    var caregiverId = _userID?.key ?? activeUser!.id;
    var plans = await _dataRepository.getPlans(caregiverId: caregiverId);
		return CaregiverPlansData(plans);
  });
}

class CaregiverPlansData extends Equatable {
	final List<Plan> plans;

	CaregiverPlansData(this.plans);

	@override
	List<Object?> get props => [plans];
}
