import 'package:mongo_dart/mongo_dart.dart';

abstract class TaskRepository {
	Future<int> getCompletedTaskCount(ObjectId planInstanceId);
}
