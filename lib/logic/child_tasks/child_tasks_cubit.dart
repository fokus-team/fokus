import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fokus/logic/child_tasks/task_instance_list_constructor.dart';
import 'package:fokus/model/ui/plan/ui_plan_instance.dart';
import 'package:fokus/model/ui/task/ui_task_instance.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:get_it/get_it.dart';

part 'child_tasks_state.dart';

class ChildTasksCubit extends Cubit<ChildTasksState> {
	final DataRepository _dataRepository = GetIt.I<DataRepository>();
  ChildTasksCubit() : super(ChildTasksInitial());

  void loadTasksInstancesFromPlanInstance(UIPlanInstance _uiPlanInstance) async {
  	if(!(state is ChildTasksInitial))
  		return;
  	var planInstanceId = _uiPlanInstance.id;
  	var allTasksInstances = await _dataRepository.getTaskInstances(planInstanceId: planInstanceId);
  	List<UITaskInstance> uiInstances = await getTaskInstanceListfromDb(allTasksInstances);
  	emit(ChildTasksLoadSuccess(uiInstances));
	}
}
