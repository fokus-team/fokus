import 'package:fokus/model/db/gamification/child_badge.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/child_permission.dart';
import 'package:fokus/utils/definitions.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../gamification/points.dart';
import '../gamification/child_reward.dart';
import 'user_role.dart';

class Child extends User {
  List<ChildPermission>? permissions;
  List<Points>? points;
  List<ChildReward>? rewards;
  List<ChildBadge>? badges;

  Child.create({String? name, int? avatar, List<ObjectId>? connections}) : this._(name: name, avatar: avatar, connections: connections);

  Child._({ObjectId? id, String? name, int? avatar, List<ObjectId>? connections, this.badges, this.permissions, this.points, this.rewards}) :
			  super(id: id, name: name, role: UserRole.child, avatar: avatar, connections: connections);

  static Child? fromJson(Json? json) {
    return json != null ? (Child._(
	    id: json['_id'],
      badges: json['badges'] != null ? (json['badges'] as List).map((i) => ChildBadge.fromJson(i)).toList() : [],
      permissions: json['permissions'] != null ? (json['badges'] as List).map((i) => ChildPermission.values[i]).toList() : [],
      points: json['points'] != null ? (json['points'] as List).map((i) => Points.fromJson(i)).toList() : [],
      rewards: json['rewards'] != null ? (json['rewards'] as List).map((i) => ChildReward.fromJson(i)).toList() : [],
    )..assignFromJson(json)) : null;
  }

  Json toJson() {
    final Json data = super.toJson();
    if (this.badges != null)
      data['badges'] = this.badges!.map((v) => v.toJson()).toList();
    if (this.permissions != null)
      data['permissions'] = this.permissions!.map((v) => v.index).toList();
    if (this.points != null)
      data['points'] = this.points!.map((v) => v.toJson()).toList();
    if (this.rewards != null)
      data['rewards'] = this.rewards!.map((v) => v.toJson()).toList();
    return data;
  }
}
