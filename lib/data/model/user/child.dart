import 'package:fokus/data/model/user/child_badge.dart';
import 'package:fokus/data/model/user/user.dart';
import 'package:fokus/data/model/user_permission.dart';

import 'child_currency.dart';
import 'child_reward.dart';
import 'user_type.dart';

class Child extends User {
  List<ChildBadge> badges;
  List<ChildPermission> permissions;
  List<ChildCurrency> points;
  List<ChildReward> rewards;

  Child({String ID, this.badges, this.permissions, this.points, this.rewards}) : super(ID: ID, type: UserType.CHILD);

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      badges: json['badges'] != null ? (json['badges'] as List).map((i) => ChildBadge.fromJson(i)).toList() : null,
      permissions: json['permissions'] != null ? (json['badges'] as List).map((i) => ChildPermission.values[i]).toList() : null,
      points: json['points'] != null ? (json['points'] as List).map((i) => ChildCurrency.fromJson(i)).toList() : null,
      rewards: json['rewards'] != null ? (json['rewards'] as List).map((i) => ChildReward.fromJson(i)).toList() : null,
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
