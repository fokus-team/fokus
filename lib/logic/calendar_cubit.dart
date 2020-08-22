import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/collection_utils.dart';
import 'package:fokus/utils/string_utils.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:mongo_dart/mongo_dart.dart';

class CalendarCubit extends Cubit<CalendarState> {
	final ActiveUserFunction _activeUser;
	Map<ObjectId, Plan> _plans;
	Map<ObjectId, String> _children;

	final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CalendarCubit(this._activeUser) : super(CalendarState());

  void loadDataForMonth(Date month) async {
	  var activeUser = _activeUser() as UICaregiver;
	  if (state.events.containsKey(month))
	  	return;
	  if (_plans == null)
	    _plans = Map.fromEntries((await _dataRepository.getPlans(caregiverId: activeUser.id, activeOnly: false)).map((plan) => MapEntry(plan.id, plan)));
	  if (_children == null)
	  	_children = await _dataRepository.getUserNames(activeUser.connections);
	  var currentMonth = Date.now();
	  currentMonth = Date(currentMonth.year, currentMonth.month, 1);
	  if (month < currentMonth)
	  	loadPastMonthData(month);
	  else if (month > currentMonth)
	  	loadFutureMonthData(month);
  }

	void loadPastMonthData(Date month) async {
  	var dateSpan = DateSpan(from: month, to: Date(month.year, month.month + 1, 1));
		var instances = await _dataRepository.getPlanInstances(planIDs: _plans.keys.toList(), between: dateSpan);
		var dateMap = groupBy<Date, PlanInstance>(instances, (plan) => plan.date);

	  Map<Date, List<UIPlan>> events;
		for (var entry in dateMap.entries) {
			var planMap = groupBy<ObjectId, PlanInstance>(entry.value, (plan) => plan.planID);
			events[entry.key] = planMap.keys.map((planId) => UIPlan.fromDBModel(_plans[planId], getDescription(planMap[planId]))).toList();
		}
		emit(state.copyWith(month, events));
	}

	void loadFutureMonthData(Date month) async {

	}

	TranslateFunc getDescription(List<PlanInstance> plans) {
		return getAssignedToDescription(plans.map((plan) => _children[plan.assignedTo]).toList());
	}

	TranslateFunc getAssignedToDescription(List<String> children) {
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
