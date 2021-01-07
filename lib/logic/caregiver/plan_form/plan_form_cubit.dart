import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/form/task_form_model.dart';
import 'package:fokus/services/plan_keeper_service.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/ui/form/plan_form_model.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/services/plan_repeatability_service.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/task.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'plan_form_state.dart';

class PlanFormCubit extends Cubit<PlanFormState> {
	final ActiveUserFunction _activeUser;
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final PlanKeeperService _planKeeperService = GetIt.I<PlanKeeperService>();
	final PlanRepeatabilityService _repeatabilityService = GetIt.I<PlanRepeatabilityService>();
	final Date _date;

  PlanFormCubit(AppFormArgument argument, this._activeUser, this._date) : super(PlanFormInitial(argument?.type ?? AppFormType.create, argument?.id));

  void loadFormData() async {
	  var user = _activeUser();
		var children = await _dataRepository.getUsers(role: UserRole.child, connected: user.id);
		var planForm;
		if(_date != null) {
			planForm = _createPlanFOrmModelWithDate();
		}
	  else planForm = state.formType == AppFormType.create ? PlanFormModel() : await _fillPlanFormModel();
		emit(PlanFormDataLoadSuccess(state, children.map((child) => UIChild.fromDBModel(child)).toList(), (user as UICaregiver).currencies, planForm));
  }

  void submitPlanForm(PlanFormModel planForm) async {
		emit(PlanFormSubmissionInProgress(state));
		var userId = _activeUser().id;

		var plan = Plan.fromPlanForm(planForm, userId, _repeatabilityService.mapRepeatabilityModel(planForm), state.formType == AppFormType.edit ? state.planId: null);
		var tasks = planForm.tasks.map((task) => Task.fromTaskForm(task, plan.id, userId, state.formType == AppFormType.edit ? task.id : null)).toList();
		plan.tasks = tasks.map((task) => task.id).toList();

		List<Future> updates;
		if (state.formType == AppFormType.create || state.formType == AppFormType.copy) {
			updates = [
		    _dataRepository.createPlan(plan),
		    _dataRepository.createTasks(tasks),
				_planKeeperService.createPlansForToday([plan], plan.assignedTo),
			];
		} else {
	    updates = [
				_dataRepository.updatePlan(plan),
				_dataRepository.updateTasks(tasks),
		    _planKeeperService.createPlansForToday([plan], plan.assignedTo),
	    ];
		}
		await Future.value(updates);
		emit(PlanFormSubmissionSuccess(state));
  }

  Future<PlanFormModel> _fillPlanFormModel() async {
  	var plan = await _dataRepository.getPlan(id: state.planId);
		var model = PlanFormModel.fromDBModel(plan);
		var tasks = await _dataRepository.getTasks(planId: state.planId);
		model.tasks = plan.tasks.map((id) => TaskFormModel.fromDBModel(tasks.firstWhere((task) => task.id == id))).toList();
		if(state.formType == AppFormType.copy) {
			model.children = [];
		}
		return model;
  }

	PlanFormModel _createPlanFOrmModelWithDate() {
  	var model = PlanFormModel();
  	model.repeatability = PlanFormRepeatability.onlyOnce;
  	model.onlyOnceDate = _date;
  	return model;
	}
}
