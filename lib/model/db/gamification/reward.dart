import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/ui/form/reward_form_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'points.dart';

class Reward {
  ObjectId id;
  int icon;
  int limit;
  String name;
  Points cost;
  ObjectId createdBy;
  TimeDate createdAt;

  Reward({this.createdBy, this.id, this.icon, this.limit, this.name, this.cost, this.createdAt});
	Reward.fromRewardForm(RewardFormModel reward, ObjectId creator, [ObjectId id]) : this(name: reward.name, id: id ?? ObjectId(), createdBy: creator,
		  limit: reward.limit, icon: reward.icon, cost: reward.pointValue != null ? Points.fromUICurrency(reward.pointCurrency, reward.pointValue, creator: creator) : null);

  factory Reward.fromJson(Map<String, dynamic> json) {
    return json != null ? Reward(
      createdBy: json['createdBy'],
      id: json['_id'],
      icon: json['icon'],
      limit: json['limit'],
      name: json['name'],
      cost: json['cost'] != null ? Points.fromJson(json['cost']) : null,
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
      data['cost'] = this.cost.toJson();
    return data;
  }
}
