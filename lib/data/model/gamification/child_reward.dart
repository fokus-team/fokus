import 'package:fokus/data/model/date/time_date.dart';

class ChildReward {
  int cost;
  TimeDate date;
  String ID;
  int quantity;

  ChildReward({this.cost, this.date, this.ID, this.quantity});

  factory ChildReward.fromJson(Map<String, dynamic> json) {
    return ChildReward(
      cost: json['cost'],
      date: TimeDate.parseDBString(json['date']),
      ID: json['ID'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cost'] = this.cost;
    data['date'] = this.date.toDBString();
    data['ID'] = this.ID;
    data['quantity'] = this.quantity;
    return data;
  }
}
