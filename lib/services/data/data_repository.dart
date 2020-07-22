import 'package:fokus/services/data/plan/plan_repository.dart';
import 'package:fokus/services/data/task/task_repository.dart';
import 'package:fokus/services/data/user/user_repository.dart';

abstract class DataRepository implements UserRepository, PlanRepository, TaskRepository {
	Future initialize();
}
