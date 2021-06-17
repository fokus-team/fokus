import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../model/db/plan/plan.dart';
import '../../model/db/plan/task.dart';
import '../../services/data/data_repository.dart';
import 'stateful/stateful_cubit.dart';

class PlanCubit extends StatefulCubit {
  final ObjectId _planId;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  PlanCubit(this._planId, ModalRoute pageRoute) : super(pageRoute);

  @override
  Future doLoadData() async {
    var plan = (await _dataRepository.getPlan(id: _planId))!;
    var children = await _dataRepository.getUserNames(plan.assignedTo!);
    var tasks = await _dataRepository.getTasks(planId: _planId);
    emit(PlanCubitState(
      plan: plan,
      tasks: tasks,
      children: children,
    ));
  }

  Future deletePlan() async {
    if (!beginSubmit()) return;
    var instances = await _dataRepository
        .getPlanInstances(planId: _planId, fields: ['_id']);
    await Future.wait([
      _dataRepository.removePlans(ids: [_planId]),
      _dataRepository.removePlanInstances(planId: _planId),
      _dataRepository.removeTasks(planIds: [_planId]),
      _dataRepository.removeTaskInstances(
          planInstancesIds: instances.map((plan) => plan.id!).toList()),
    ]);
    emit(state.submissionSuccess());
  }
}

class PlanCubitState extends StatefulState {
  final Plan plan;
  final List<Task> tasks;
  final Map<ObjectId, String> children;

  PlanCubitState({
    required this.plan,
    required this.tasks,
    required this.children,
    DataSubmissionState? submissionState,
  }) : super.loaded(submissionState);

  @override
  StatefulState withSubmitState(DataSubmissionState submissionState) =>
      PlanCubitState(
        plan: plan,
        tasks: tasks,
        children: children,
        submissionState: submissionState,
      );

  @override
  List<Object?> get props => super.props..addAll([plan, tasks, children]);
}
