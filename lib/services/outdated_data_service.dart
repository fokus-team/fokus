import 'dart:async';

import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';

import 'data/data_repository.dart';

class OutdatedDataService {
	final DataRepository _dbRepository = GetIt.I<DataRepository>();
	Timer _dataCheckTimer;
	ObjectId _userId;
	UserRole _role;

	void onUserLogin(ObjectId userId, UserRole role) {
		_userId = userId;
		_role = role;

		onUserLogout();
		_updateOutdatedData();
		var now = DateTime.now();
		Duration timeToMidnight = DateTime(now.year, now.month, now.day + 1).difference(now);
		_dataCheckTimer = Timer(timeToMidnight, _firstTimerCallback);
	}

	void onUserLogout() {
		if (_dataCheckTimer != null)
			_dataCheckTimer.cancel();
	}

	void _firstTimerCallback() {
		_updateOutdatedData();
		_dataCheckTimer = Timer.periodic(Duration(days: 1), (_) => _updateOutdatedData());
	}

	Future _updateOutdatedData() async {
		var getRoleId = (UserRole paramRole) => paramRole == _role ? _userId : null;
		var plans = await _dbRepository.getPlans(caregiverId: getRoleId(UserRole.caregiver),
				childId: getRoleId(UserRole.child), fields: ['_id'], oneDayOnly: true, activeOnly: false);

		var childrenIDs = _role == UserRole.caregiver ? (await _dbRepository.getCaregiverChildren(_userId, ['_id'])).map((child) => child.id).toList() : [_userId];
		var instances = await _dbRepository.getPastNotCompletedPlanInstances(childrenIDs, plans.map((plan) => plan.id).toList(), Date.now(), fields: ['_id', 'date']);

		var getEndTime = (Date date) => TimeDate.fromDate(date.add(Duration(days: 1)));
		var plansByDate = groupBy<PlanInstance, Date>(instances, (plan) => plan.date);

		List<Future> updates = [];
		for (var date in plansByDate.entries)
			updates.add(_dbRepository.updatePlanInstances(date.value.map((plan) => plan.id).toList(), state: PlanInstanceState.lostForever, end: getEndTime(date.key)));
		return Future.wait(updates);
		// TODO there are also 'to' fields in task instance last 'duration' and 'breaks' objects that could be left missing here - handle here or inside statistics code
	}
}
