import 'package:mongo_dart/mongo_dart.dart';

import 'points.dart';

class Reward {
  ObjectId id;
  int icon;
  int limit;
  String name;
  Points points;
  ObjectId createdBy;

  Reward({this.createdBy, this.id, this.icon, this.limit, this.name, this.points});

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      createdBy: json['createdBy'],
      id: json['_id'],
      icon: json['icon'],
      limit: json['limit'],
      name: json['name'],
      points: json['points'] != null ? Points.fromJson(json['points']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdBy'] = this.createdBy;
    data['_id'] = this.id;
    data['icon'] = this.icon;
    data['limit'] = this.limit;
    data['name'] = this.name;
    if (this.points != null) {
      data['points'] = this.points.toJson();
    }
    return data;
  }
}
