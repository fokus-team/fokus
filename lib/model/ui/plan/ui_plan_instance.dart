import 'package:equatable/equatable.dart';

import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/utils/duration_utils.dart';

class UIPlanInstance extends Equatable {
	final PlanInstance instance;
	final Plan plan;
	final int? completedTaskCount;

	int Function()? get elapsedActiveTime => instance.duration != null ? () => sumDurations(instance.duration).inSeconds : null;

	String? get description {
	  if (plan.repeatability == null)
	    return null;
	  return PlanRepeatabilityService.buildPlanDescription(plan.repeatability!, instanceDate: instance.date);
	}

	UIPlanInstance({required this.instance, required this.plan, this.completedTaskCount});

	@override
  List<Object?> get props => [instance, plan, completedTaskCount];
}
