import 'package:bson/bson.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/user/ui_user.dart';

class UIChild extends UIUser {
	final int todayPlanCount;
	final bool hasActivePlan;
	final Map<CurrencyType, int> points;
	final Map<CurrencyType, String> pointsNames;

  UIChild(ObjectId id, String name, {this.todayPlanCount = 0, this.hasActivePlan = false, this.points = const {}, this.pointsNames = const {}, int avatar = -1}) :
			  super(id, name, role: UserRole.child, avatar: avatar);
  UIChild.fromDBModel(Child child, {this.todayPlanCount = 0, this.hasActivePlan = false}):
			  points = child.points != null ? Map.fromEntries(child.points.map((type) => MapEntry(type.icon, type.quantity))) : {},
				pointsNames = child.points != null ? Map.fromEntries(child.points.map((currency) => MapEntry(currency.icon, currency.name))) : {},
				super.fromDBModel(child);

	UIChild copyWith({Map<CurrencyType, int> points}) {
		return UIChild(
			id,
			name,
			points: points ?? this.points,
			todayPlanCount: todayPlanCount,
			hasActivePlan: hasActivePlan,
			avatar: avatar
		);
	}

	@override
	List<Object> get props => super.props..addAll([todayPlanCount, hasActivePlan, points]);
}
