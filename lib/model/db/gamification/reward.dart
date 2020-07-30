import 'package:mongo_dart/mongo_dart.dart';

import 'points.dart';

class Reward {
  ObjectId id;
  int icon;
  int limit;
  String name;
  Points cost;
  ObjectId createdBy;

  Reward({this.createdBy, this.id, this.icon, this.limit, this.name, this.cost});

  factory Reward.fromJson(Map<String, dynamic> json) {
    return json != null ? Reward(
      createdBy: json['createdBy'],
      id: json['_id'],
      icon: json['icon'],
      limit: json['limit'],
      name: json['name'],
      cost: json['cost'] != null ? Points.fromJson(json['points']) : null,
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdBy'] = this.createdBy;
    data['_id'] = this.id;
    data['icon'] = this.icon;
    data['limit'] = this.limit;
    data['name'] = this.name;
    if (this.cost != null) {
      data['cost'] = this.cost.toJson();
    }
    return data;
  }
}
