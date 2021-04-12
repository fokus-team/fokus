import 'package:fokus/model/db/date/date_base.dart';
import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/services/data/award/award_repository.dart';
import 'package:fokus/services/data/currency/currency_repository.dart';
import 'package:fokus/services/data/plan/plan_repository.dart';
import 'package:fokus/services/data/task/task_repository.dart';
import 'package:fokus/services/data/user/user_repository.dart';

abstract class DataRepository implements UserRepository, PlanRepository, TaskRepository, AwardRepository, CurrencyRepository {
	Future initialize();
}

class DateSpanUpdate<D extends DateBase> {
	D value;
	SpanDateType type;
	int index;

	DateSpanUpdate(this.value, this.type, [this.index = -1]);
}
