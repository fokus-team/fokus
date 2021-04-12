import 'package:fokus/model/db/date/date.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PlanFormParams {
	final AppFormType type;
	final ObjectId? id;
	final Date? date;

	PlanFormParams({required this.type, this.id, this.date});
}
