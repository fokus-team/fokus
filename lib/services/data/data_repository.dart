import 'package:fokus/model/db/date/date_base.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/services/data/award/award_repository.dart';
import 'package:fokus/services/data/plan/plan_repository.dart';
import 'package:fokus/services/data/task/task_repository.dart';
import 'package:fokus/services/data/user/user_repository.dart';

abstract class DataRepository implements UserRepository, PlanRepository, TaskRepository, AwardRepository {
	Future initialize();
}

class DateSpanUpdate<D extends DateBase> {
	D value;
	SpanDateType type;
	int index = -1;

	DateSpanUpdate(this.value, this.type, [this.index]);
}
