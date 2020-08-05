import 'package:fokus/model/db/date/time_date.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ChildReward {
  int cost;
  TimeDate date;
  ObjectId id;
  int quantity;

  ChildReward({this.cost, this.date, this.id, this.quantity});

  factory ChildReward.fromJson(Map<String, dynamic> json) {
    return json != null ? ChildReward(
      cost: json['cost'],
      date: TimeDate.parseDBDate(json['date']),
      id: json['_id'],
      quantity: json['quantity'],
    ) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cost'] = this.cost;
    data['date'] = this.date.toDBDate();
    data['_id'] = this.id;
    data['quantity'] = this.quantity;
    return data;
  }
}
