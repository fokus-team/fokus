import 'points.dart';

class Reward {
  int createdBy;
  String ID;
  int icon;
  int limit;
  String name;
  Points points;

  Reward({this.createdBy, this.ID, this.icon, this.limit, this.name, this.points});

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      createdBy: json['createdBy'],
      ID: json['_id'],
      icon: json['icon'],
      limit: json['limit'],
      name: json['name'],
      points: json['points'] != null ? Points.fromJson(json['points']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdBy'] = this.createdBy;
    data['_id'] = this.ID;
    data['icon'] = this.icon;
    data['limit'] = this.limit;
    data['name'] = this.name;
    if (this.points != null) {
      data['points'] = this.points.toJson();
    }
    return data;
  }
}
