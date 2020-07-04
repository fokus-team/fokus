import 'package:mongo_dart/mongo_dart.dart';

class Points {
  ObjectId id;
  int quantity;

  Points({this.id, this.quantity});

  factory Points.fromJson(Map<String, dynamic> json) {
    return Points(
      id: json['_id'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['quantity'] = this.quantity;
    return data;
  }
}
