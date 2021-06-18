import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:date_utils/date_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../model/db/date/date.dart';
import '../../model/db/date_span.dart';
import '../../model/db/plan/plan.dart';
import '../../model/db/plan/plan_instance.dart';
import '../../model/db/user/caregiver.dart';
import '../../model/db/user/child.dart';
import '../../model/db/user/user_role.dart';
import '../../services/data/data_repository.dart';
import '../../services/model_helpers/plan_repeatability_service.dart';
import '../../utils/definitions.dart';

class CalendarCubit extends Cubit<CalendarState> {
	final ActiveUserFunction _activeUser;
	final ObjectId? _initialFilter;
	late Map<ObjectId, Plan> _plans;
	late Map<ObjectId, String> _childNames;
	final Map<Date, Map<Date, List<Plan>>> _allEvents = {};

	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  CalendarCubit(this._initialFilter, this._activeUser) : super(CalendarState(day: Date.now()));

  void loadInitialData() async {
	  var activeUser = _activeUser();
	  getRoleId(UserRole paramRole) => paramRole == activeUser.role ? activeUser.id : null;
	  _plans = Map.fromEntries(_planEntries(await _dataRepository.getPlans(caregiverId: getRoleId(UserRole.caregiver),
			  childId: getRoleId(UserRole.child), active: true)));

	  Map<Child?, bool> filter;
	  if (activeUser.role == UserRole.caregiver) {
		  var children = await _dataRepository.getUsers(ids: (activeUser as Caregiver).connections);
		  _childNames = Map.fromEntries(children.map((child) => MapEntry(child.id!, child.name!)));
		  filter = Map.fromEntries(children.map((child) => MapEntry(child as Child, false)));

			if(_initialFilter != null) {
				var childSetByID = children.firstWhereOrNull((element) => element.id == _initialFilter);
				if(childSetByID != null)
					filter[childSetByID as Child] = true;
			}
	  } else {
		  _childNames = {activeUser.id!: activeUser.name!};
		  filter = {activeUser as Child: true};
	  }
	  var events = await _filterData(filter, state.day);
	  emit(state.copyWith(children: filter, events: events));
  }
  
  void childFilterChanged(Map<Child?, bool> filter) async => emit(state.copyWith(children: filter, events: await _filterData(filter, state.day)));

  void dayChanged(Date day) async => emit(state.copyWith(day: day));

  void monthChanged(Date month) async => emit(state.copyWith(day: month, events: await _filterData(state.children, month)));

	Future<Map<Date, List<Plan>>> _filterData(Map<Child?, bool>? filter, Date date) async {
		var month = Date.fromDate(DateUtils.firstDayOfMonth(date));
		if (filter == null)
			return {};

		var filterNotApplied = filter.values.every((element) => element == false);
		var ids = filterNotApplied ?
			filter.keys.map((child) => child!.id).toSet()
			: filter.keys.where((child) => filter[child]!).map((child) => child!.id).toSet();

		var events = <Date, List<Plan>>{};
		var monthEvents = _allEvents[month] ?? await _loadDataForMonth(month);
		for (var day in monthEvents.entries) {
			var plans = <Plan>[];
			for (var plan in day.value) {
				if (filterNotApplied || (!filterNotApplied && ids.any(plan.assignedTo!.contains)))
					plans.add(plan);
			}
			events[day.key] = plans;
		}
		return events;
	}

	Future<Map<Date, List<Plan>>> _loadDataForMonth(Date month) async {
	  if (_allEvents.containsKey(month))
	  	return _allEvents[month]!;
	  var currentMonth = Date.fromDate(DateUtils.firstDayOfMonth(Date.now()));

	  var events = <Date, List<Plan>>{};
	  if (month < currentMonth)
		  events.addAll(await _loadPastData(_getMonthSpan(month)));
	  else if (month > currentMonth)
		  events.addAll(_loadFutureData(_getMonthSpan(month)));
	  else {
		  events.addAll(await _loadPastData(DateSpan(from: month, to: Date.now()))); // TODO handle today better
		  events.addAll(_loadFutureData(DateSpan(from: Date.now(), to: Date.fromDate(DateUtils.nextMonth(month)))));
	  }
	  _allEvents.putIfAbsent(Date.fromDate(DateUtils.firstDayOfMonth(month)), () => events);
	  return events;
  }

  /// [span] - must fit within a month (from 1'st to the end)
	Future<Map<Date, List<Plan>>> _loadPastData(DateSpan<Date> span) async {
		var instances = await _dataRepository.getPlanInstances(childIDs: _childNames.keys.toList(), between: span);
		var unassignedPlanIDs = instances.map((plan) => plan.planID!).where((id) => !_plans.keys.contains(id)).toList();
		var pastPlans = Map<ObjectId, Plan>.from(_plans)..addEntries(_planEntries(await _dataRepository.getPlans(ids: unassignedPlanIDs)));
		var dateMap = groupBy<PlanInstance, Date>(instances, (plan) => plan.date!);

		planWithAssigned(MapEntry<ObjectId, List<PlanInstance>> planEntry) {
			var plan = pastPlans[planEntry.key]!;
		  return plan.copyWith(assignedTo: planEntry.value.map((instance) => instance.assignedTo!).toList());
		};
	  var events = <Date, List<Plan>>{};
		for (var entry in dateMap.entries) {
			var planToInstanceMap = groupBy<PlanInstance, ObjectId>(entry.value, (plan) => plan.planID!);
			events[entry.key] = planToInstanceMap.entries.map(planWithAssigned).toList();
		}
		return events;
	}

	Iterable<MapEntry<ObjectId, Plan>> _planEntries(List<Plan> plans) => plans.map((plan) => MapEntry(plan.id!, plan));

	Map<Date, List<Plan>> _loadFutureData(DateSpan<Date> span) {
		var events = <Date, List<Plan>>{};
		for (var plan in _plans.entries) {
			var dates = _repeatabilityService.getRepeatabilityDatesInSpan(plan.value.repeatability!, span);
			for (var date in dates)
				(events[date] ??= []).add(plan.value);
		}
		return events;
	}

	DateSpan<Date> _getMonthSpan(Date month) => DateSpan(from: month, to: Date.fromDate(DateUtils.nextMonth(month)));

}

class CalendarState extends Equatable {
	final Map<Child?, bool>? children;
	final Date day;
	final Map<Date, List<Plan>>? events;

	const CalendarState({required this.day, this.children, this.events});

	CalendarState copyWith({Map<Child?, bool>? children, Map<Date, List<Plan>>? events, Date? day}) {
	  return CalendarState(
		  children: children ?? this.children,
		  events: events ?? this.events,
		  day: day ?? this.day
	  );
	}

	@override
	List<Object?> get props => [events, children, day];
}
