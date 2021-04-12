// @dart = 2.10
import 'dart:math';

import 'package:date_utils/date_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/repeatability_type.dart';
import 'package:fokus/model/db/plan/plan_repeatability.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/string_utils.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/ui/form/plan_form_model.dart';

import 'data/data_repository.dart';

class PlanRepeatabilityService {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	/// [span] - must fit within a month (from 1'st to the end)
	List<Date> getRepeatabilityDatesInSpan(PlanRepeatability repeatability, DateSpan<Date> span) {
		if ((repeatability.range?.from != null && repeatability.range.from >= span.to) || (repeatability.range?.to != null && repeatability.range.to < span.from))
			return [];
		var day = (int index) => repeatability.days[max(index, 0)];
		List<Date> dates = [];
		var iterateDays = (int startDay, int baseLength) {
			var dayIndex = repeatability.days.indexWhere((day) => day >= startDay);
			int daysJump = day(dayIndex) - startDay;
			if (dayIndex == -1) {
				dayIndex = 0;
				daysJump += baseLength;
			}
			var date = Date(span.from.year, span.from.month, span.from.day + daysJump);
			while (date < span.to && (repeatability.range?.to == null || date <= repeatability.range.to)) {
				if ((repeatability.range?.from == null || date >= repeatability.range?.from))
					dates.add(Date.fromDate(date));
				var gap = day((dayIndex + 1) % repeatability.days.length) - day(dayIndex);
				date = Date(date.year, date.month, date.day + (gap > 0 ? gap : gap + baseLength));
				dayIndex = (dayIndex + 1) % repeatability.days.length;
			}
		};
		if (repeatability.type == RepeatabilityType.once) {
			if (span.contains(repeatability.range.from, includeTo: false))
				dates.add(repeatability.range.from);
		} else if (repeatability.type == RepeatabilityType.weekly)
			iterateDays(span.from.weekday, 7);
		else if (repeatability.type == RepeatabilityType.monthly)
			iterateDays(span.from.day, DateUtils.lastDayOfMonth(span.from).day);
		return dates;
	}

	Future<int> getPlanCountByDate(ObjectId childId, Date date) async {
		return filterPlansByDate(await _dataRepository.getPlans(childId: childId, fields: ['repeatability', 'active']), date).length;
	}

	List<Plan> filterPlansByDate(List<Plan> plans, Date date, {bool activeOnly = true}) {
		return plans.where((plan) => (!activeOnly || plan.active) && _planInstanceExistsByDate(plan, date)).toList();
	}

	PlanRepeatability mapRepeatabilityModel(PlanFormModel planForm) {
		RepeatabilityType type = planForm.repeatability == PlanFormRepeatability.recurring ? planForm.repeatabilityRage.dbType : RepeatabilityType.once;
		var untilCompleted = planForm.repeatability == PlanFormRepeatability.untilCompleted;
		var range = DateSpan.from(planForm.rangeDate);
		if (type == RepeatabilityType.once)
			range.from = planForm.onlyOnceDate;
		return PlanRepeatability(type: type, untilCompleted: untilCompleted, range: range, days: planForm.days..sort());
	}

	static PlanFormRepeatability getFormRepeatability(PlanRepeatability repeatability) {
		if (repeatability.untilCompleted)
			return PlanFormRepeatability.untilCompleted;
		return repeatability.type == RepeatabilityType.once ? PlanFormRepeatability.onlyOnce : PlanFormRepeatability.recurring;
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
		  var formatDate = (date) => DateFormat.yMd(AppLocales.instance.locale.toString()).format(date);
  		String description = '';
		  if (rules.untilCompleted && instanceDate != null)
			  description += AppLocales.of(context).translate('repeatability.startedOn', {'DAY': formatDate(instanceDate)});
		  else if (rules.type == RepeatabilityType.once)
		  	description += AppLocales.of(context).translate('repeatability.once', {'DAY': formatDate(rules.range.from)});
			else {
				String andWord = AppLocales.of(context).translate('and');
			  if (rules.type == RepeatabilityType.weekly) {
					if(rules.days.length == 7) {
						description += AppLocales.of(context).translate('date.everyday');
					} else {
						List<String> weekdays = rules.days.map((day) => AppLocales.of(context).translate('repeatability.weekday', {'WEEKDAY': '$day'})).toList();
						String weekdayString = displayJoin(weekdays, andWord);
						description += '${AppLocales.of(context).translate('repeatability.weekly', {'WEEKDAY': '${rules.days[0]}'})} $weekdayString';
					}
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
