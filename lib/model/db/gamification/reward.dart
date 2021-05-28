import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/ui/gamification/ui_reward.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/utils/definitions.dart';

import 'points.dart';

class Reward {
  ObjectId? id;
  int? icon;
  int? limit;
  String? name;
  Points? cost;
  ObjectId? createdBy;
  TimeDate? createdAt;

  Reward({this.createdBy, this.id, this.icon, this.limit, this.name, this.cost, this.createdAt});
  Reward.fromUIModel(UIReward reward, ObjectId creator, [ObjectId? id]) : this(name: reward.name, id: id ?? ObjectId(), createdBy: creator,
		  limit: reward.limit, icon: reward.icon, cost: reward.cost != null ? Points.fromUIPoints(reward.cost!) : null);

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
}
