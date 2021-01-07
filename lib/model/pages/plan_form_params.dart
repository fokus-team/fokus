import 'package:fokus/model/db/date/date.dart';
import 'package:mongo_dart/mongo_dart.dart';

enum AppFormType { create, edit, copy }

class PlanFormParams {
	final AppFormType type;
	final ObjectId id;
	final Date date;

	PlanFormParams({this.type, this.id, this.date});
}
