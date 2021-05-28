import 'package:fokus/model/db/date/time_date.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/utils/definitions.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ChildReward {
	ObjectId? id;
	String? name;
  Points? cost;
  TimeDate? date;
	int? icon;

  ChildReward({this.id, this.name, this.cost, this.date, this.icon});

  static ChildReward? fromJson(Json? json) {
    return json != null ? ChildReward(
      id: json['_id'],
      name: json['name'],
      cost: Points.fromJson(json['cost']),
      date: TimeDate.parseDBDate(json['date']),
      icon: json['icon'],
    ) : null;
  }

  Json toJson() {
    final Json data = new Json();
    if (this.id != null)
      data['_id'] = this.id;
    if (this.name != null)
      data['name'] = this.name;
    if (this.cost != null)
      data['cost'] = this.cost!.toJson();
    if (this.date != null)
      data['date'] = this.date!.toDBDate();
    if (this.icon != null)
      data['icon'] = this.icon;
    return data;
  }
}
