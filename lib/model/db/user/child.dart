import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/definitions.dart';
import '../gamification/child_badge.dart';
import '../gamification/child_reward.dart';
import '../gamification/points.dart';
import 'child_permission.dart';
import 'user.dart';
import 'user_role.dart';

class Child extends User {
  final List<ChildPermission>? permissions;
  final List<Points>? points;
  final List<ChildReward>? rewards;
  final List<ChildBadge>? badges;

  Child.create({String? name, int? avatar, List<ObjectId>? connections}) : this._(name: name, avatar: avatar, connections: connections, id: ObjectId());

  Child._({
	  ObjectId? id,
	  String? name,
	  int? avatar,
	  List<ObjectId>? connections,
	  String? locale,
	  this.badges = const [],
	  this.permissions = const [],
	  this.points = const [],
	  this.rewards = const [],
  }) : super(id: id, name: name, role: UserRole.child, avatar: avatar, connections: connections, locale: locale);

  Child.fromJson(Json json) :
      badges = json['badges'] != null ? (json['badges'] as List).map((i) => ChildBadge.fromJson(i)).toList() : [],
      permissions = json['permissions'] != null ? (json['badges'] as List).map((i) => ChildPermission.values[i]).toList() : [],
      points = json['points'] != null ? (json['points'] as List).map((i) => Points.fromJson(i)).toList() : [],
      rewards = json['rewards'] != null ? (json['rewards'] as List).map((i) => ChildReward.fromJson(i)).toList() : [],
      super.fromJson(json);

  @override
  Json toJson() {
    final data = super.toJson();
    if (badges != null)
      data['badges'] = badges!.map((v) => v.toJson()).toList();
    if (permissions != null)
      data['permissions'] = permissions!.map((v) => v.index).toList();
    if (points != null)
      data['points'] = points!.map((v) => v.toJson()).toList();
    if (rewards != null)
      data['rewards'] = rewards!.map((v) => v.toJson()).toList();
    return data;
  }

  Child.copyFrom(Child user, {String? locale, String? name, List<ChildBadge>? badges, List<Points>? points}) :
		  points = points ?? user.points,
		  badges = badges ?? user.badges,
		  rewards = user.rewards,
	    permissions = user.permissions,
		  super.copyFrom(user, locale: locale, name: name);

  @override
  List<Object?> get props => super.props..addAll([badges, permissions, points, rewards]);
}
