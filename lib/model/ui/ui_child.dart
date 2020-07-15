import 'package:bson/bson.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/ui_user.dart';

class UIChild extends UIUser {
	int todayPlanCount;
	bool hasActivePlan;
	Map<CurrencyType, int> points;

  UIChild(ObjectId id, String name, {int avatar = -1}) : super(id, name, role: UserRole.child, avatar: avatar);

	@override
	List<Object> get props => [id, todayPlanCount, hasActivePlan, points];
}
