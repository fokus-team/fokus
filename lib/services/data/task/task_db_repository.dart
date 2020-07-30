import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/services/data/db/db_repository.dart';

mixin TaskDbRepository implements DbRepository {
	Future<int> getCompletedTaskCount(ObjectId planInstanceId) {
		return dbClient.count(Collection.taskInstance, where.eq('planInstanceID', planInstanceId).and(where.eq('status.completed', true)));
	}
}
