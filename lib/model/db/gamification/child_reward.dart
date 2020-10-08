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
    if (this.cost != null)
      data['cost'] = this.cost;
    if (this.date != null)
      data['date'] = this.date.toDBDate();
    if (this.id != null)
      data['_id'] = this.id;
    if (this.quantity != null)
      data['quantity'] = this.quantity;
    return data;
  }
}
