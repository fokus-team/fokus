import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/plan_instance_state.dart';
import 'package:fokus/model/db/plan/task_instance.dart';
import 'package:fokus/utils/duration_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/data_repository.dart';

class ActiveTaskService {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	static final String key = 'isAnyTaskActive';

	void setTaskStateActive() async {
		final prefs = await SharedPreferences.getInstance();
		prefs.setBool(key, true);
	}

	void setTaskStateInactive() async {
		final prefs = await SharedPreferences.getInstance();
		prefs.setBool(key, false);
	}

	static void removeTaskState() async {
		final prefs = await SharedPreferences.getInstance();
		prefs.remove(key);
	}

	static Future<bool> getActiveTaskState() async {
		final prefs = await SharedPreferences.getInstance();
		final isActive = prefs.getBool(key) ?? null;
		return isActive;
	}

	Future<bool> isAnyTaskActive({List<PlanInstance> planInstances, ObjectId childId}) async {
		bool isActive = await getActiveTaskState();
		if(isActive != null) return isActive;
		if(planInstances == null) {
			planInstances = await _dataRepository.getPlanInstances(childIDs: [childId]);
		}
		if(planInstances.any((element) => element.state == PlanInstanceState.active)) {
			List<TaskInstance> taskInstances = await _dataRepository.getTaskInstances(planInstanceId: planInstances.firstWhere((element) => element.state == PlanInstanceState.active).id);
			for(var instance in taskInstances) {
				if(isInProgress(instance.duration) || isInProgress(instance.breaks)) {
					setTaskStateActive();
					return true;
				}
			}
		}
		setTaskStateInactive();
		return false;
	}
}
