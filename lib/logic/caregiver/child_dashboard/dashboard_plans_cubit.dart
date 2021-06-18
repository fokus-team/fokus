import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../model/db/date/date.dart';
import '../../../model/db/plan/plan.dart';
import '../../../model/db/plan/task_status.dart';
import '../../../model/db/user/child.dart';
import '../../../model/ui/plan/ui_plan_instance.dart';
import '../../../services/data/data_repository.dart';
import '../../../services/model_helpers/ui_data_aggregator.dart';
import '../../../services/plan_keeper_service.dart';
import '../../common/stateful/stateful_cubit.dart';

class DashboardPlansCubit extends StatefulCubit {
	late Child child;
	late List<Plan> _availablePlans;
	
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
	final UIDataAggregator _dataAggregator = GetIt.I<UIDataAggregator>();
	final PlanKeeperService _planKeeperService = GetIt.I<PlanKeeperService>();
	
  DashboardPlansCubit(ModalRoute pageRoute) : super(pageRoute, options: [StatefulOption.noAutoLoading, StatefulOption.resetSubmissionState]);

  @override
  Future doLoadData() async {
	  var planInstances = (await _dataRepository.getPlanInstances(childIDs: [child.id!], fields: ['_id'])).map((plan) => plan.id!).toList();
	  var data = await Future.wait([
		  _dataAggregator.loadTodaysPlanInstances(childId: child.id!),
		  _dataRepository.countTaskInstances(planInstancesId: planInstances, isCompleted: true, state: TaskState.notEvaluated),
		  _dataRepository.countPlans(caregiverId: activeUser!.id),
		  _dataRepository.getPlans(caregiverId: activeUser!.id),
	  ]);
	  _availablePlans = (data[3] as List<Plan>).where((plan) {
	    var toDate = plan.repeatability!.range?.to;
	    return toDate == null || toDate >= Date.now();
	  }).toList();
	  emit(DashboardPlansState(
		  childPlans: data[0] as List<UIPlanInstance>,
		  availablePlans: _availablePlans,
		  unratedTasks: (data[1] as int) > 0,
		  noPlansAdded: (data[2] as int) == 0
	  ));
  }

	Future assignPlans(List<ObjectId?> ids) => submitData(body: () async {
		var tabState = state as DashboardPlansState;
		var childID = child.id!;
		filterAssigned(bool Function(Plan) condition) => tabState.availablePlans.where(condition).map((plan) => plan.id!).toList();
		var assignedIds = filterAssigned((plan) => ids.contains(plan.id) && !plan.assignedTo!.contains(childID));
		var unassignedIds = filterAssigned((plan) => !ids.contains(plan.id) && plan.assignedTo!.contains(childID));
		var assignedPlans = _availablePlans.where((plan) => assignedIds.contains(plan.id)).toList()
			..forEach((plan) => plan.assignedTo!.add(childID));
		var results = await Future.wait([
			_dataRepository.updatePlanFields(assignedIds, assign: childID),
			_dataRepository.updatePlanFields(unassignedIds, unassign: childID),
			_planKeeperService.createPlansForToday(assignedPlans, [childID])
		]);
		updateAssigned(Plan plan) {
			var assignedTo = List.of(plan.assignedTo!);
			if (assignedIds.contains(plan.id))
				assignedTo.add(childID);
			else if (unassignedIds.contains(plan.id))
				assignedTo.remove(childID);
			return assignedTo;
		};
		var newPlans = tabState.availablePlans.map((plan) => plan.copyWith(assignedTo: updateAssigned(plan))).toList();
		var childPlans = List<UIPlanInstance>.of(tabState.childPlans)
			..addAll(await _dataAggregator.getUIPlanInstances(plans: assignedPlans, instances: results[2]));
		emit(tabState.copyWith(availablePlans: newPlans, childPlans: childPlans, submissionState: DataSubmissionState.submissionSuccess));
	});
}

class DashboardPlansState extends StatefulState {
	final List<UIPlanInstance> childPlans;
	final List<Plan> availablePlans;
	final bool noPlansAdded;
	final bool unratedTasks;

	DashboardPlansState({
		required this.childPlans,
		required this.availablePlans,
		required this.noPlansAdded,
		required this.unratedTasks,
		DataSubmissionState? submissionState,
	}) : super.loaded(submissionState);

	DashboardPlansState copyWith({List<Plan>? availablePlans, List<UIPlanInstance>? childPlans, DataSubmissionState? submissionState}) {
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
	List<Object?> get props => super.props..addAll([childPlans, availablePlans, noPlansAdded, unratedTasks]);
}
