import 'package:equatable/equatable.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/utils/definitions.dart';

import 'points.dart';

class Reward extends Equatable {
  final ObjectId? id;
  final int? icon;
  final int? limit;
  final String? name;
  final Points? cost;
  final ObjectId? createdBy;

  Reward({this.createdBy, this.id, this.icon, this.limit, this.name, this.cost});
  Reward.fromUIModel(UIReward reward, ObjectId creator, [ObjectId? id]) : this(name: reward.name, id: id ?? ObjectId(), createdBy: creator,
		  limit: reward.limit, icon: reward.icon, cost: reward.cost);

  static Reward? fromJson(Json? json) {
    return json != null ? Reward(
      createdBy: json['createdBy'],
      id: json['_id'],
      icon: json['icon'],
      limit: json['limit'],
      name: json['name'],
      cost: json['cost'] != null ? Points.fromJson(json['cost']) : null,
    ) : null;
  }

  Json toJson() {
    final Json data = new Json();
    if (this.createdBy != null)
	    data['createdBy'] = this.createdBy;
    if (this.id != null)
	    data['_id'] = this.id;
    if (this.icon != null)
	    data['icon'] = this.icon;
    if (this.limit != null)
	    data['limit'] = this.limit;
    if (this.name != null)
	    data['name'] = this.name;
    if (this.cost != null)
      data['cost'] = this.cost!.toJson();
    return data;
  }

  @override
  List<Object?> get props => [id, icon, limit, name, cost, createdBy];
}
