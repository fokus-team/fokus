import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import '../../model/db/plan/plan.dart';
import '../../model/db/plan/task.dart';
import '../../services/data/data_repository.dart';
import 'cubit_base.dart';

class PlanCubit extends CubitBase<PlanData> {
  final ObjectId _planId;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  PlanCubit(this._planId, ModalRoute pageRoute) : super(pageRoute);

  @override
  Future reload(_) => load(body: () async {
    var plan = (await _dataRepository.getPlan(id: _planId))!;
    var children = await _dataRepository.getUserNames(plan.assignedTo!);
    var tasks = await _dataRepository.getTasks(planId: _planId);
    return Action.finish(PlanData(
      plan: plan,
      tasks: tasks,
      children: children,
    ));
  });

  Future deletePlan() => submit(body: () async {
    var instances = await _dataRepository.getPlanInstances(planId: _planId, fields: ['_id']);
    await Future.wait([
	    _dataRepository.removePlans(ids: [_planId]),
	    _dataRepository.removePlanInstances(planId: _planId),
	    _dataRepository.removeTasks(planIds: [_planId]),
	    _dataRepository.removeTaskInstances(planInstancesIds: instances.map((plan) => plan.id!).toList()),
    ]);
  });
}

class PlanData extends Equatable {
  final Plan plan;
  final List<Task> tasks;
  final Map<ObjectId, String> children;

  PlanData({
    required this.plan,
    required this.tasks,
    required this.children,
  });

  @override
  List<Object?> get props => [plan, tasks, children];
}
