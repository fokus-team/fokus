import 'package:mongo_dart/mongo_dart.dart';

import '../db/date/date.dart';
import '../ui/app_page.dart';

class PlanFormParams {
	final AppFormType type;
	final ObjectId? id;
	final Date? date;

	PlanFormParams({required this.type, this.id, this.date});
}
