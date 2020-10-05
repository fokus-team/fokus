import 'package:bson/bson.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/user/ui_user.dart';

class UIChild extends UIUser {
	final int todayPlanCount;
	final bool hasActivePlan;
	final List<UIPoints> points;
	final List<UIChildReward> rewards;
	final List<UIChildBadge> badges;
	final List<ObjectId> connections;

  UIChild(ObjectId id, String name, {this.todayPlanCount = 0, this.hasActivePlan = false, this.connections = const [], this.points = const [], this.rewards = const [], this.badges = const [], int avatar = -1}) :
			super(id, name, role: UserRole.child, avatar: avatar);
  UIChild.fromDBModel(Child child, {this.todayPlanCount = 0, this.hasActivePlan = false}):
			connections = child.connections ?? [],
			points = child.points != null ? child.points.map((e) => UIPoints(type: e.icon, title: e.name, createdBy: e.createdBy, quantity: e.quantity)).toList() : [],
			rewards = child.rewards != null ? child.rewards.map((e) => UIChildReward(id: e.id, name: e.name, cost: UIPoints.fromDBModel(e.cost), icon: e.icon, date: e.date)).toList() : [],
			badges = child.badges != null ? child.badges.map((e) => UIChildBadge(name: e.name, description: e.description, icon: e.icon, date: e.date)).toList() : [],
			super.fromDBModel(child);

	UIChild copyWith({List<UIPoints> points, List<UIChildReward> rewards, List<UIChildBadge> badges}) {
		return UIChild(
			id,
			name,
			avatar: avatar,
			connections: connections,
			points: points ?? this.points,
			rewards: rewards ?? this.rewards,
			badges: badges ?? this.badges,
			todayPlanCount: todayPlanCount,
			hasActivePlan: hasActivePlan
		);
	}

	@override
	List<Object> get props => super.props..addAll([todayPlanCount, hasActivePlan, points, rewards, badges, connections]);
}
