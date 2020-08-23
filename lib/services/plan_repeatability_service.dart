import 'package:date_utils/date_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:fokus/model/ui/form/plan_form_model.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/repeatability_type.dart';
import 'package:fokus/model/db/plan/plan_repeatability.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/string_utils.dart';

import 'data/data_repository.dart';

class PlanRepeatabilityService {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	List<Date> getRepeatabilityDatesInMonth(PlanRepeatability repeatability, Date month) {
		var day = (int index) => repeatability.days[index];
		var nextDayGap = (int index) {
			var gap = repeatability.days[(index + 1) % repeatability.days.length] - day(index);
			return gap > 0 ? gap : gap + 7;
		};
		List<Date> dates = [];

		if (repeatability.type == RepeatabilityType.once) {
			if (Utils.firstDayOfMonth(repeatability.range.from) == month)
				dates.add(repeatability.range.from);
		} else if (repeatability.type == RepeatabilityType.weekly) {
			var weekdayIndex = repeatability.days.indexWhere((day) => day >= month.weekday);
			int daysJump = day(weekdayIndex) - month.weekday;
			if (weekdayIndex == -1) {
				weekdayIndex = 0;
				daysJump += 7;
			}
			var date = Date(month.year, month.month, daysJump);
			while (date.month == month.month) {
				dates.add(Date.fromDate(date));
				date = Date(date.year, date.month, date.day + nextDayGap(weekdayIndex));
				weekdayIndex = (weekdayIndex + 1) % repeatability.days.length;
			}
		} else if (repeatability.type == RepeatabilityType.monthly) {
			for (var day in repeatability.days) {
				var date = Date(month.year, month.month, day);
				if (date.month > month.month)
					break;
				dates.add(Date(month.year, month.month, day));
			}
		}
		return dates;
	}

	Future<List<Plan>> getPlansByDate(ObjectId childId, Date date, {bool activeOnly = true}) async {
		return filterPlansByDate(await _dataRepository.getPlans(childId: childId, activeOnly: activeOnly), date);
	}

	Future<List<Plan>> filterPlansByDate(List<Plan> plans, Date date, {bool activeOnly = true}) async {
		return plans.where((plan) => _planInstanceExistsByDate(plan, date)).toList();
	}

	PlanRepeatability mapRepeatabilityModel(PlanFormModel planForm) {
		RepeatabilityType type = planForm.repeatability == PlanFormRepeatability.recurring ? planForm.repeatabilityRage.dbType : RepeatabilityType.once;
		var untilCompleted = planForm.repeatability == PlanFormRepeatability.untilCompleted;
		return PlanRepeatability(type: type, untilCompleted: untilCompleted, range: planForm.rangeDate, days: planForm.days);
	}

	static PlanFormRepeatability getFormRepeatability(PlanRepeatability repeatability) {
		if (repeatability.type == RepeatabilityType.once)
			return PlanFormRepeatability.onlyOnce;
		return repeatability.untilCompleted ? PlanFormRepeatability.untilCompleted : PlanFormRepeatability.recurring;
	}

  bool _planInstanceExistsByDate(Plan plan, Date date) {
  	var rules = plan.repeatability;
	  if (rules.range?.from != null && rules.range.from > date)
		  return false;
  	if (rules.type == RepeatabilityType.once && rules.range.from == date)
  		return true;
	  if (rules.type == RepeatabilityType.weekly && rules.days.contains(date.weekday))
		  return true;
	  if (rules.type == RepeatabilityType.monthly && rules.days.contains(date.day))
		  return true;
	  return false;
  }

	TranslateFunc buildPlanDescription(PlanRepeatability rules, {Date instanceDate, bool detailed = false}) {
  	return (context) {
		  var formatDate = (date) => DateFormat.yMd(Localizations.localeOf(context).toString()).format(date);
  		String description = '';
		  if (rules.untilCompleted && instanceDate != null)
			  description += AppLocales.of(context).translate('repeatability.startedOn', {'DAY': formatDate(instanceDate)});
		  else if (rules.type == RepeatabilityType.once)
		  	description += AppLocales.of(context).translate('repeatability.once', {'DAY': formatDate(rules.range.from)});
			else {
				String andWord = AppLocales.of(context).translate('and');
			  if (rules.type == RepeatabilityType.weekly) {
					List<String> weekdays = rules.days.map((day) => AppLocales.of(context).translate('repeatability.weekday', {'WEEKDAY': '$day'})).toList();
					String weekdayString = displayJoin(weekdays, andWord);
				  description += '${AppLocales.of(context).translate('repeatability.weekly', {'WEEKDAY': '${rules.days[0]}'})} $weekdayString';
			  }
			  else if (rules.type == RepeatabilityType.monthly) {
				  String dayString = displayJoin(rules.days.map((day) => '$day').toList(), andWord);
				  description += AppLocales.of(context).translate('repeatability.monthly', {'DAYS': dayString});
			  }
		  }
			if (!detailed)
				return description;
			if (rules.range.to != null)
		    description += ', ${AppLocales.of(context).translate('repeatability.range', {'FROM': formatDate(rules.range.from), 'TO': formatDate(rules.range.to)})}';
			if (rules.untilCompleted)
		  description += ', ${AppLocales.of(context).translate('repeatability.untilCompleted')}';
		  return description;
	  };
  }
}
