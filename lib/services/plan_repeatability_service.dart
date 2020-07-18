import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/repeatability_type.dart';

import 'database/data_repository.dart';

class PlanRepeatabilityService {
	final DataRepository _dbProvider = GetIt.I<DataRepository>();

  Future<List<Plan>> getChildPlansByDate(ObjectId childId, Date date, {bool activeOnly = true}) async {
    var childPlans = await _dbProvider.getChildPlans(childId, activeOnly: activeOnly);
    return childPlans.where((plan) => planInstanceExistsByDate(plan, date)).toList();
  }

  bool planInstanceExistsByDate(Plan plan, Date date) {
  	var rules = plan.repeatability;
	  if (rules.range.from > date)
		  return false;
  	if (rules.type == RepeatabilityType.once && rules.range.from == date)
  		return true;
	  if (rules.type == RepeatabilityType.weekly && rules.days.contains(date.weekday))
		  return true;
	  if (rules.type == RepeatabilityType.monthly && rules.days.contains(date.day))
		  return true;
	  return false;
  }
}
