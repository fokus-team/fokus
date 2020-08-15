import 'dart:async';

import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/date_span.dart';

import 'data/data_repository.dart';

class OutdatedDataService {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();

	Timer _dataCheckTimer;
	ObjectId _userId;
	UserRole _role;

	void onUserSignIn(ObjectId userId, UserRole role) {
		_userId = userId;
		_role = role;

		onUserSignOut();
		_updateOutdatedData();
		var now = DateTime.now();
		Duration timeToMidnight = DateTime(now.year, now.month, now.day + 1).difference(now);
		_dataCheckTimer = Timer(timeToMidnight, _firstTimerCallback);
	}

	void onUserSignOut() {
		if (_dataCheckTimer != null)
			_dataCheckTimer.cancel();
	}

	void _firstTimerCallback() {
		_updateOutdatedData();
		_dataCheckTimer = Timer.periodic(Duration(days: 1), (_) => _updateOutdatedData());
	}

	Future _updateOutdatedData() async {
		var getRoleId = (UserRole paramRole) => paramRole == _role ? _userId : null;
		var plans = await _dataRepository.getPlans(caregiverId: getRoleId(UserRole.caregiver),
				childId: getRoleId(UserRole.child), fields: ['_id'], oneDayOnly: true, activeOnly: false);

		var childrenIDs = _role == UserRole.caregiver ? (await _dataRepository.getUsers(role: UserRole.child, connected: _userId, fields: ['_id'])).map((child) => child.id).toList() : [_userId];
		var instances = await _dataRepository.getPastNotCompletedPlanInstances(childrenIDs, plans.map((plan) => plan.id).toList(), Date.now(), fields: ['_id', 'date', 'duration', 'state']);

		var getEndTime = (Date date) => TimeDate.fromDate(date.add(Duration(days: 1)));

		List<Future> updates = [];
		for (var instance in instances)
			updates.add(_dataRepository.updatePlanInstances(
				instance.id,
				state: await _determineFinalPlanState(instance),
				durationChange: DateSpanUpdate<TimeDate>(getEndTime(instance.date), SpanDateType.end, instance.duration.length - 1))
			);
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
