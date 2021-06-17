import '../../model/db/date/date_base.dart';
import '../../model/db/date_span.dart';
import 'award/award_repository.dart';
import 'currency/currency_repository.dart';
import 'plan/plan_repository.dart';
import 'task/task_repository.dart';
import 'user/user_repository.dart';

abstract class DataRepository implements UserRepository, PlanRepository, TaskRepository, AwardRepository, CurrencyRepository {
	Future initialize();
}

class DateSpanUpdate<D extends DateBase> {
	D value;
	SpanDateType type;
	int index;

	DateSpanUpdate(this.value, this.type, [this.index = -1]);
}
