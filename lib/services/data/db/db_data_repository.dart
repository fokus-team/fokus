import 'package:get_it/get_it.dart';

import 'package:fokus/services/remote_config_provider.dart';

import 'db_repository.dart';
import 'mongodb_provider.dart';
import '../plan/plan_db_repository.dart';
import '../user/user_db_repository.dart';
import '../data_repository.dart';
import '../task/task_db_repository.dart';

class DbDataRepository with UserDbRepository, PlanDbRepository, TaskDbRepository implements DataRepository, DbRepository {
	@override
	final MongoDbProvider client = MongoDbProvider();

	@override
	Future initialize() async => client.initialize(GetIt.I<RemoteConfigProvider>().dbAccessString);
}
