import 'package:equatable/equatable.dart';

import '../../../services/plan_repeatability_service.dart';
import '../../../utils/definitions.dart';
import '../../../utils/duration_utils.dart';
import '../../db/plan/plan.dart';
import '../../db/plan/plan_instance.dart';

class UIPlanInstance extends Equatable {
	final PlanInstance instance;
	final Plan plan;
	final int? completedTaskCount;

	ElapsedTime? get elapsedActiveTime => instance.duration != null ? () => sumDurations(instance.duration).inSeconds : null;

	String? get description {
	  if (plan.repeatability == null)
	    return null;
	  return PlanRepeatabilityService.buildPlanDescription(plan.repeatability!, instanceDate: instance.date);
	}

	UIPlanInstance({required this.instance, required this.plan, this.completedTaskCount});

	@override
  List<Object?> get props => [instance, plan, completedTaskCount];
}
