import 'package:fokus/model/db/gamification/child_badge.dart';
import 'package:fokus/model/db/user/user.dart';
import 'package:fokus/model/db/user/child_permission.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../gamification/points.dart';
import '../gamification/child_reward.dart';
import 'user_role.dart';

class Child extends User {
  List<ChildBadge> badges;
  List<ChildPermission> permissions;
  List<Points> points;
  List<ChildReward> rewards;

  Child({ObjectId id, this.badges, this.permissions, this.points, this.rewards}) : super(id: id, role: UserRole.child);

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
	    id: json['_id'],
      badges: json['badges'] != null ? (json['badges'] as List).map((i) => ChildBadge.fromJson(i)).toList() : [],
      permissions: json['permissions'] != null ? (json['badges'] as List).map((i) => ChildPermission.values[i]).toList() : [],
      points: json['points'] != null ? (json['points'] as List).map((i) => Points.fromJson(i)).toList() : [],
      rewards: json['rewards'] != null ? (json['rewards'] as List).map((i) => ChildReward.fromJson(i)).toList() : [],
    )..fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.badges != null) {
      data['badges'] = this.badges.map((v) => v.toJson()).toList();
    }
    if (this.permissions != null) {
      data['permissions'] = this.permissions.map((v) => v.index).toList();
    }
    if (this.points != null) {
      data['points'] = this.points.map((v) => v.toJson()).toList();
    }
    if (this.rewards != null) {
      data['rewards'] = this.rewards.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
