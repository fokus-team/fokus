import 'package:bson/bson.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/ui_user.dart';

class UIChild extends UIUser {
	final int todayPlanCount;
	final bool hasActivePlan;
	final Map<CurrencyType, int> points;

  UIChild(ObjectId id, String name, {this.todayPlanCount = 0, this.hasActivePlan = false, this.points = const {}, int avatar = -1}) :
			  super(id, name, role: UserRole.child, avatar: avatar);
  UIChild.fromDBModel(Child child, {int todayPlanCount = 0, bool hasActivePlan = false}): this(child.id, child.name, avatar: child.avatar,
		  points: Map.fromEntries(child.points.map((type) => MapEntry(type.icon, type.quantity))), todayPlanCount: todayPlanCount, hasActivePlan: hasActivePlan);

	@override
	List<Object> get props => [id, todayPlanCount, hasActivePlan, points];

	@override
  String toString() => 'UIChild{name: $name, todayPlanCount: $todayPlanCount, hasActivePlan: $hasActivePlan, points: $points}';
}
