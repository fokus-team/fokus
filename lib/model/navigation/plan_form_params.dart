// @dart = 2.10
import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PlanFormParams {
	final AppFormType type;
	final ObjectId id;
	final Date date;

	PlanFormParams({this.type, this.id, this.date});
}
