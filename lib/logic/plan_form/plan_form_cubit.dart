import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/plan/ui_plan_form.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/ui/user/ui_user.dart';

part 'plan_form_state.dart';

class PlanFormCubit extends Cubit<PlanFormState> {
	final AppFormType formType;
	
	final ActiveUserFunction _activeUser;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();

  PlanFormCubit(this.formType, this._activeUser) : super(PlanFormInitial());

  void submitPlanForm(UIPlanForm planForm) async {
		emit(PlanFormSubmissionInProgress());
		var userId = _activeUser().id;
		if (formType == AppFormType.create) {
			var plan = Plan.fromPlanForm(planForm, userId, _repeatabilityService.mapRepeatabilityModel(planForm));
			plan.id = await _dataRepository.createPlan(plan);
			var tasks = planForm.tasks.map((task) => Task.fromTaskForm(task, plan.id, userId)).toList();
			var taskIds = await _dataRepository.createTasks(tasks);
			await _dataRepository.updatePlan(plan.id, addedTasks: taskIds);
		}
		emit(PlanFormSubmissionSuccess());
  }
}
