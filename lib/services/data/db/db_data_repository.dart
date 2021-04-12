import 'package:fokus/services/data/award/award_db_repository.dart';
import 'package:fokus/services/data/currency/currency_db_repository.dart';

import 'db_repository.dart';
import 'mongodb_provider.dart';

import '../award/award_db_repository.dart';
import '../plan/plan_db_repository.dart';
import '../user/user_db_repository.dart';
import '../data_repository.dart';
import '../task/task_db_repository.dart';

class DbDataRepository with UserDbRepository, PlanDbRepository, TaskDbRepository, AwardDbRepository, CurrencyDbRepository implements DataRepository, DbRepository {
	@override
	final MongoDbProvider dbClient = MongoDbProvider();

	@override
	Future initialize() async => dbClient.connect(firstTime: true);
}
