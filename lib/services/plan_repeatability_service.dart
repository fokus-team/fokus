import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/repeatability_type.dart';
import 'package:fokus/model/db/plan/plan_repeatability.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/string_utils.dart';

import 'data/data_repository.dart';

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

	TranslateFunc buildPlanDescription(PlanRepeatability rules, {bool detailed = false}) {
  	var formatDate = (date) => DateFormat.yMd().format(date);
  	return (context) {
  		String description = '';
		  if (rules.type == RepeatabilityType.once)
		  	description += AppLocales.of(context).translate('repeatability.once', {'day': formatDate(rules.range.from)});
			else {
				String andWord = AppLocales.of(context).translate('and');
			  if (rules.type == RepeatabilityType.weekly) {
					List<String> weekdays = rules.days.map((day) => AppLocales.of(context).translate('repeatability.weekday', {'weekday': '$day'})).toList();
					String weekdayString = StringUtils.displayJoin(weekdays, andWord);
				  description += '${AppLocales.of(context).translate('repeatability.weekly', {'weekday': '${rules.days[0]}'})} $weekdayString';
			  }
			  else if (rules.type == RepeatabilityType.monthly) {
				  String dayString = StringUtils.displayJoin(rules.days.map((day) => '$day').toList(), andWord);
				  description += AppLocales.of(context).translate('repeatability.monthly', {'days': dayString});
			  }
		  }
			if (!detailed)
				return description;
			if (rules.range.to != null)
		    description += ', ${AppLocales.of(context).translate('repeatability.range', {'from': formatDate(rules.range.from), 'to': formatDate(rules.range.to)})}';
			if (rules.untilCompleted)
		  description += ', ${AppLocales.of(context).translate('repeatability.untilCompleted')}';
		  return description;
	  };
  }
}
