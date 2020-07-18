import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';

import 'database/data_repository.dart';

class PlanRepeatabilityService {
	final DataRepository _dbProvider = GetIt.I<DataRepository>();

  Future<List<Plan>> getChildPlansByDate(ObjectId childId, Date date, {bool activeOnly = true}) async {
    var childPlans = await _dbProvider.getChildPlans(childId, activeOnly: activeOnly);

    return childPlans;
  }
}
