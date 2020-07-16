import 'package:mongo_dart/mongo_dart.dart';

class Points {
  ObjectId currencyId;
  int quantity;

  Points({this.currencyId, this.quantity});

  factory Points.fromJson(Map<String, dynamic> json) {
    return Points(
      currencyId: json['_id'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.currencyId;
    data['quantity'] = this.quantity;
    return data;
  }
}
