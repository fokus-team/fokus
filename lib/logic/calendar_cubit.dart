import 'package:bloc/bloc.dart';
import 'package:date_utils/date_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/utils/collection_utils.dart';
import 'package:fokus/utils/string_utils.dart';

class CalendarCubit extends Cubit<CalendarState> {
	final ActiveUserFunction _activeUser;
	Map<ObjectId, Plan> _plans;
	Map<ObjectId, String> _children;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  CalendarCubit(this._activeUser) : super(CalendarState());

  void loadDataForMonth(Date month) async {
	  var activeUser = _activeUser() as UICaregiver;
	  if (state.events.containsKey(month))
	  	return;
	  if (_plans == null)
	    _plans = Map.fromEntries((await _dataRepository.getPlans(caregiverId: activeUser.id, activeOnly: false)).map((plan) => MapEntry(plan.id, plan)));
	  if (_children == null)
	  	_children = await _dataRepository.getUserNames(activeUser.connections);
	  var currentMonth = Date.fromDate(Utils.firstDayOfMonth(Date.now()));

	  Map<Date, List<UIPlan>> events = {};
	  if (month < currentMonth)
		  events.addAll(loadFutureData(getMonthSpan(month)));
	  else if (month > currentMonth)
		  events.addAll(loadFutureData(getMonthSpan(month)));
	  else {
		  events.addAll(await loadPastData(DateSpan(from: month, to: Date.now()))); // TODO handle today better
		  events.addAll(loadFutureData(DateSpan(from: Date.now(), to: Utils.nextMonth(month))));
	  }
	  emit(state.copyWith(Utils.firstDayOfMonth(month), events));
  }


  /// [span] - must fit within a month (from 1'st to the end)
	Future<Map<Date, List<UIPlan>>> loadPastData(DateSpan<Date> span) async {
		var instances = await _dataRepository.getPlanInstances(planIDs: _plans.keys.toList(), between: span);
		var dateMap = groupBy<Date, PlanInstance>(instances, (plan) => plan.date);

	  Map<Date, List<UIPlan>> events = {};
		for (var entry in dateMap.entries) {
			var planMap = groupBy<ObjectId, PlanInstance>(entry.value, (plan) => plan.planID);
			events[entry.key] = planMap.keys.map((planId) => UIPlan.fromDBModel(_plans[planId], _getDescription(planMap[planId]))).toList();
		}
		return events;
	}

	Map<Date, List<UIPlan>> loadFutureData(DateSpan<Date> span) {
		Map<Date, List<UIPlan>> events = {};
		for (var plan in _plans.entries) {
			var dates = _repeatabilityService.getRepeatabilityDatesInSpan(plan.value.repeatability, span);
			for (var date in dates)
				(events[date] ??= []).add(UIPlan.fromDBModel(plan.value, _getAssignedToDescription(plan.value.assignedTo.map((child) => _children[child]).toList())));
		}
		return events;
	}

	DateSpan<Date> getMonthSpan(Date month) => DateSpan(from: month, to: Utils.nextMonth(month));

	TranslateFunc _getDescription(List<PlanInstance> plans) {
		return _getAssignedToDescription(plans.map((plan) => _children[plan.assignedTo]).toList());
	}

	TranslateFunc _getAssignedToDescription(List<String> children) {
		return (context) => AppLocales.of(context).translate('assignedTo') + ': ' + displayJoin(children, AppLocales.of(context).translate('and'));
	}
}

class CalendarState extends Equatable {
	final Map<Date, Map<Date, List<UIPlan>>> events;

	const CalendarState([this.events = const {}]);

	CalendarState copyWith(Date month, Map<Date, List<UIPlan>> events) => CalendarState(this.events..putIfAbsent(month, () => events));

	@override
	List<Object> get props => [events];
}
