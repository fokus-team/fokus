import 'package:bson/bson.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/db/user/child.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/gamification/ui_badge.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:fokus/model/ui/user/ui_user.dart';

class UIChild extends UIUser {
	final int? todayPlanCount;
	final bool? hasActivePlan;
	final List<Points>? points;
	final List<UIChildReward>? rewards;
	final List<UIChildBadge>? badges;

  UIChild(ObjectId? id, String? name, {this.todayPlanCount = 0, this.hasActivePlan = false, List<ObjectId>? connections = const [],
	    this.points = const [], this.rewards = const [], this.badges = const [], int? avatar = -1}) :
			super(id, name, role: UserRole.child, avatar: avatar, connections: connections);
  UIChild.fromDBModel(Child child, {this.todayPlanCount = 0, this.hasActivePlan = false}):
			points = child.points ?? [],
			rewards = child.rewards != null ? child.rewards!.map((reward) => UIChildReward.fromDBModel(reward)).toList() : [],
			badges = child.badges != null ? child.badges!.map((badge) => UIChildBadge.fromDBModel(badge)).toList() : [],
			super.fromDBModel(child);

	UIChild copyWith({List<Points>? points, List<UIChildReward>? rewards, List<UIChildBadge>? badges}) {
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

	UIChild.from(UIChild original, {String? locale, String? name, List<UIChildBadge>? badges, List<Points>? points}) :
			todayPlanCount = original.todayPlanCount,
			hasActivePlan = original.hasActivePlan,
			points = points ?? original.points,
			badges = badges ?? original.badges,
			rewards = original.rewards,
			super.from(original, locale: locale, name: name);

	@override
	List<Object?> get props => super.props..addAll([todayPlanCount, hasActivePlan, points, rewards, badges]);
}
