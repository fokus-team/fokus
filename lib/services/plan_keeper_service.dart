import 'dart:async';

import 'package:fokus/model/db/user/user.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/model/db/date_span.dart';

import 'active_user_observer.dart';
import 'data/data_repository.dart';

class PlanKeeperService implements ActiveUserObserver {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

	Timer _dataCheckTimer;
	ObjectId _userId;
	UserRole _role;

	@override
	Future onUserSignIn(User user) async {
		return Future.sync(() async {
			_userId = user.id;
			_role = user.role;

			onUserSignOut(user);
			await _updateData();
			var now = DateTime.now();
			Duration timeToMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 10).difference(now);
			_dataCheckTimer = Timer(timeToMidnight, _firstTimerCallback);
		});
	}

	@override
	void onUserSignOut(User user) {
		if (_dataCheckTimer != null)
			_dataCheckTimer.cancel();
	}

	void _firstTimerCallback() {
		_updateData();
		_dataCheckTimer = Timer.periodic(Duration(days: 1), (_) => _updateData());
	}

	Future _updateData() async {
		var getRoleId = (UserRole paramRole) => paramRole == _role ? _userId : null;
		var plans = await _dataRepository.getPlans(caregiverId: getRoleId(UserRole.caregiver),
				childId: getRoleId(UserRole.child), fields: ['_id', 'repeatability', 'active', 'assignedTo', 'tasks']);
		var children = await _dataRepository.getUsers(role: UserRole.child, connected: _userId, fields: ['_id']);
		var childrenIDs = _role == UserRole.caregiver ? children.map((child) => child.id).toList() : [_userId];

		return Future.wait([
			_createPlansForToday(plans, childrenIDs),
			_updateOutdatedData(plans, childrenIDs)
		]);
	}

	Future _createPlansForToday(List<Plan> plans, List<ObjectId> childrenIDs) async {
		var todayPlans = await _repeatabilityService.filterPlansByDate(plans.where((plan) => plan.active).toList(), Date.now());
		for (var plan in todayPlans) {
			var instances = childrenIDs.where(plan.assignedTo.contains).map((child) => PlanInstance.fromPlan(plan, assignedTo: child)).toList();
			await _dataRepository.createPlanInstances(instances);
		}
	}

	Future _updateOutdatedData(List<Plan> plans, List<ObjectId> childrenIDs) async {
		var planIDs = plans.where((plan) => !plan.repeatability.untilCompleted).map((plan) => plan.id).toList();
		var instances = await _dataRepository.getPastNotCompletedPlanInstances(childrenIDs, planIDs, Date.now(), fields: ['_id', 'date', 'duration', 'state']);
		var getEndTime = (Date date) => TimeDate.fromDate(date.add(Duration(days: 1)));

		List<Future> updates = [];
		for (var instance in instances)
			updates.add(_dataRepository.updatePlanInstances(
				instance.id,
				state: await _determineFinalPlanState(instance),
				durationChange: instance.duration.isNotEmpty ? DateSpanUpdate<TimeDate>(getEndTime(instance.date), SpanDateType.end, instance.duration.length - 1) : null
			));
		return Future.wait(updates);
		// TODO there are also 'to' fields in task instance last 'duration' and 'breaks' objects that could be left missing here - handle here or inside statistics code
	}

	Future<PlanInstanceState> _determineFinalPlanState(PlanInstance instance) async {
		if (instance.state == PlanInstanceState.notStarted)
			return PlanInstanceState.lostForever;
		var tasks = await _dataRepository.getTaskInstances(planInstanceId: instance.id, requiredOnly: true, fields: ['status.completed']);
		return tasks.every((task) => task.status.completed) ? PlanInstanceState.completed : PlanInstanceState.lostForever;
	}
}
