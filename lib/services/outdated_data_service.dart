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


	Future updateOutdatedData(ObjectId userId, UserRole role) async {
		var getRoleId = (UserRole paramRole) => paramRole == role ? userId : null;
		var plans = await _dbRepository.getPlans(caregiverId: getRoleId(UserRole.caregiver),
				childId: getRoleId(UserRole.child), fields: ['_id'], oneDayOnly: true, activeOnly: false);
		var instances = await _dbRepository.getPastNotCompletedPlanInstances(userId, plans.map((plan) => plan.id).toList(), Date.now(), fields: ['_id']);

		var getEndTime = (Date date) => TimeDate.fromDate(date.add(Duration(days: 1)));
		var plansByDate = groupBy<PlanInstance, Date>(instances, (plan) => plan.date);

		List<Future> updates = [];
		for (var date in plansByDate.entries)
			updates.add(_dbRepository.updatePlanInstances(date.value.map((plan) => plan.id), state: PlanInstanceState.lostForever, end: getEndTime(date.key)));
		return Future.wait(updates);
		// TODO there are also 'to' fields in task instance last 'duration' and 'breaks' objects that could be left missing here - handle here or inside statistics code
	}
}
