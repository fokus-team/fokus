import 'package:flutter/widgets.dart';
import 'package:fokus/model/db/plan/plan.dart';
import 'package:fokus/model/db/plan/plan_instance.dart';
import 'package:fokus/model/db/plan/task_status.dart';
import 'package:fokus/services/plan_keeper_service.dart';
import 'package:fokus/services/ui_data_aggregator.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/ui/plan/ui_plan.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DashboardPlansCubit extends StatefulCubit {
	final ActiveUserFunction _activeUser;
	UIChild child;
	List<Plan> _availablePlans;
	
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();
	final PlanKeeperService _planKeeperService = GetIt.I<PlanKeeperService>();
	
  DashboardPlansCubit(this._activeUser, ModalRoute pageRoute) : super(pageRoute, options: [StatefulOption.noAutoLoading, StatefulOption.repeatableSubmission]);

  @override
  Future doLoadData() async {
	  var activeUser = _activeUser();
	  var planInstances = (await _dataRepository.getPlanInstances(childIDs: [child.id], fields: ['_id'])).map((plan) => plan.id).toList();
	  var data = await Future.wait([
		  _dataAggregator.loadTodaysPlanInstances(childId: child.id),
		  _dataRepository.countTaskInstances(planInstancesId: planInstances, isCompleted: true, state: TaskState.notEvaluated),
		  _dataRepository.countPlans(caregiverId: activeUser.id),
		  _dataRepository.getPlans(caregiverId: activeUser.id),
	  ]);
	  _availablePlans = data[3];
	  var availablePlans = _availablePlans.map((plan) => UIPlan.fromDBModel(plan)).toList();
	  emit(DashboardPlansState(
		  childPlans: data[0],
		  availablePlans: availablePlans,
		  unratedTasks: (data[1] as int) > 0,
		  noPlansAdded: (data[2] as int) == 0
	  ));
  }

	Future assignPlans(List<ObjectId> ids) async {
		if (!beginSubmit())
			return;
		DashboardPlansState tabState = state;
		var filterAssigned = (bool Function(UIPlan) condition) => tabState.availablePlans.where(condition).map((plan) => plan.id).toList();
		var assignedIds = filterAssigned((plan) => ids.contains(plan.id) && !plan.assignedTo.contains(child.id));
		var unassignedIds = filterAssigned((plan) => !ids.contains(plan.id) && plan.assignedTo.contains(child.id));
		var assignedPlans = _availablePlans.where((plan) => assignedIds.contains(plan.id)).toList()..forEach((plan) => plan.assignedTo.add(child.id));
		await Future.wait([
			_dataRepository.updatePlanFields(assignedIds, assign: child.id),
			_dataRepository.updatePlanFields(unassignedIds, unassign: child.id),
			_planKeeperService.createPlansForToday(assignedPlans, [child.id])
		]);
		var updateAssigned = (UIPlan plan) {
			var assignedTo = List.of(plan.assignedTo);
			if (assignedIds.contains(plan.id))
				assignedTo.add(child.id);
			else if (unassignedIds.contains(plan.id))
				assignedTo.remove(child.id);
			return assignedTo;
		};
		var newPlans = tabState.availablePlans.map((plan) => plan.copyWith(assignedTo: updateAssigned(plan))).toList();
		var existingChildPlanIds = tabState.childPlans.map((plan) => plan.planId).toSet();
		var newChildPlans = assignedPlans.where((plan) => !existingChildPlanIds.contains(plan.id)).toList();
		List<UIPlanInstance> childPlans;
		if (newChildPlans.isNotEmpty) {
			var newChildPlanInstances = newChildPlans.map((e) => PlanInstance.fromPlan(e, assignedTo: child.id)).toList();
			childPlans = List.of(tabState.childPlans)..addAll(await _dataAggregator.getUIPlanInstances(plans: newChildPlans, instances: newChildPlanInstances));
		}
		emit(tabState.copyWith(availablePlans: newPlans, childPlans: childPlans, submissionState: DataSubmissionState.submissionSuccess));
	}
}

class DashboardPlansState extends StatefulState {
	final List<UIPlanInstance> childPlans;
	final List<UIPlan> availablePlans;
	final bool noPlansAdded;
	final bool unratedTasks;

	DashboardPlansState({this.childPlans, this.availablePlans, this.noPlansAdded, this.unratedTasks, DataSubmissionState submissionState}) : super.loaded(submissionState);

	DashboardPlansState copyWith({List<UIPlan> availablePlans, List<UIPlanInstance> childPlans, DataSubmissionState submissionState}) {
		return DashboardPlansState(
			childPlans: childPlans ?? this.childPlans,
			availablePlans: availablePlans ?? this.availablePlans,
			noPlansAdded: noPlansAdded,
			unratedTasks: unratedTasks,
			submissionState: submissionState
		);
	}

	@override
  StatefulState withSubmitState(DataSubmissionState submissionState) => copyWith(submissionState: submissionState);

  @override
	List<Object> get props => super.props..addAll([childPlans, availablePlans, noPlansAdded, unratedTasks]);
}
