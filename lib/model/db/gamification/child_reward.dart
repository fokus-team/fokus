import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ChildReward {
	ObjectId id;
	String name;
  Points cost;
  TimeDate date;
	int icon;

  ChildReward({this.id, this.name, this.cost, this.date, this.icon});

  factory ChildReward.fromJson(Map<String, dynamic> json) {
    return json != null ? ChildReward(
      id: json['_id'],
      name: json['name'],
      cost: Points.fromJson(json['cost']),
      date: TimeDate.parseDBDate(json['date']),
      icon: json['icon'],
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['name'] = this.name;
    data['cost'] = this.cost.toJson();
    data['date'] = this.date.toDBDate();
    data['icon'] = this.icon;
    return data;
  }
}
