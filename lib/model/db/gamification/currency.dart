import 'package:mongo_dart/mongo_dart.dart';

class Currency {
  ObjectId id;
  String name;
  int icon;
  ObjectId createdBy;

  Currency({this.createdBy, this.id, this.icon, this.name});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      createdBy: json['createdBy'],
      id: json['_id'],
      icon: json['icon'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdBy'] = this.createdBy;
    data['_id'] = this.id;
    data['icon'] = this.icon;
    data['name'] = this.name;
    return data;
  }
}
