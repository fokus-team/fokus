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
	Map<ObjectId, String> _childNames;
	Map<Date, Map<Date, List<UIPlan>>> _allEvents;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  CalendarCubit(this._activeUser) : super(CalendarState());
  
  void childFilterChanged(Map<UIUser, bool> filter) async => emit(state.copyWith(children: filter, events: await _filterData(filter, state.month)));

  void monthChanged(Date month) async => emit(state.copyWith(month: month, events: await _filterData(state.children, month)));

	Future<Map<Date, List<UIPlan>>> _filterData(Map<UIUser, bool> filter, Date month) async {
		var ids = filter.keys.map((child) => child.id).toSet();
		Map<Date, List<UIPlan>> events = {};
		if (ids.length > 0) {
			var monthEvents = _allEvents[state.month] ?? await _loadDataForMonth(state.month);
			for (var day in monthEvents.entries) {
				List<UIPlan> plans = [];
				for (var plan in day.value)
					if (ids.any(plan.assignedTo.contains))
						plans.add(plan.copyWith(description: _getDescription(plan.assignedTo.where(ids.contains))));
				events[day.key] = plans;
			}
		}
		return events;
	}

	Future<Map<Date, List<UIPlan>>> _loadDataForMonth(Date month) async {
	  var activeUser = _activeUser() as UICaregiver;
	  if (_allEvents.containsKey(month))
	  	return _allEvents[month];
	  if (_plans == null)
	    _plans = Map.fromEntries((await _dataRepository.getPlans(caregiverId: activeUser.id)).map((plan) => MapEntry(plan.id, plan)));
	  var state = this.state;
	  if (_childNames == null) {
	  	var children = await _dataRepository.getUsers(ids: activeUser.connections);
	  	state = state.copyWith(children: Map.fromEntries(children.map((child) => MapEntry(UIUser.fromDBModel(child), true))));
		  _childNames = Map.fromEntries(children.map((child) => MapEntry(child.id, child.name)));
	  }
	  var currentMonth = Date.fromDate(Utils.firstDayOfMonth(Date.now()));

	  Map<Date, List<UIPlan>> events = {};
	  if (month < currentMonth)
		  events.addAll(_loadFutureData(_getMonthSpan(month)));
	  else if (month > currentMonth)
		  events.addAll(_loadFutureData(_getMonthSpan(month)));
	  else {
		  events.addAll(await _loadPastData(DateSpan(from: month, to: Date.now()))); // TODO handle today better
		  events.addAll(_loadFutureData(DateSpan(from: Date.now(), to: Utils.nextMonth(month))));
	  }
	  _allEvents.putIfAbsent(Utils.firstDayOfMonth(month), () => events);
	  return events;
  }

  /// [span] - must fit within a month (from 1'st to the end)
	Future<Map<Date, List<UIPlan>>> _loadPastData(DateSpan<Date> span) async {
		var instances = await _dataRepository.getPlanInstances(planIDs: _plans.keys.toList(), between: span);
		var dateMap = groupBy<Date, PlanInstance>(instances, (plan) => plan.date);

	  Map<Date, List<UIPlan>> events = {};
		for (var entry in dateMap.entries) {
			var planMap = groupBy<ObjectId, PlanInstance>(entry.value, (plan) => plan.planID);
			events[entry.key] = planMap.keys.map((planId) => UIPlan.fromDBModel(_plans[planId])).toList();
		}
		return events;
	}

	Map<Date, List<UIPlan>> _loadFutureData(DateSpan<Date> span) {
		Map<Date, List<UIPlan>> events = {};
		for (var plan in _plans.entries) {
			var dates = _repeatabilityService.getRepeatabilityDatesInSpan(plan.value.repeatability, span);
			for (var date in dates)
				(events[date] ??= []).add(UIPlan.fromDBModel(plan.value));
		}
		return events;
	}

	DateSpan<Date> _getMonthSpan(Date month) => DateSpan(from: month, to: Utils.nextMonth(month));

	TranslateFunc _getDescription(Iterable<ObjectId> children) {
		return _getAssignedToDescription(children.map((id) => _childNames[id]));
	}

	TranslateFunc _getAssignedToDescription(List<String> children) {
		return (context) => AppLocales.of(context).translate('assignedTo') + ': ' + displayJoin(children, AppLocales.of(context).translate('and'));
	}
}

class CalendarState extends Equatable {
	final Map<UIUser, bool> children;
	final Date month;
	final Map<Date, List<UIPlan>> events;

	const CalendarState({this.month, this.children, this.events});

	CalendarState copyWith({Map<UIUser, bool> children, Map<Date, List<UIPlan>> events, Date month}) {
	  return CalendarState(
		  children: children ?? this.children,
		  events: events ?? this.events,
		  month: month ?? this.month
	  );
	}

	@override
	List<Object> get props => [events, children, month];
}
