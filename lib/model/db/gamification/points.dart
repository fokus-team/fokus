import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Points extends Currency {
	ObjectId createdBy;
  int quantity;

  Points({String name, CurrencyType icon, this.createdBy, this.quantity}) : super(name : name, icon: icon);

  factory Points.fromJson(Map<String, dynamic> json) {
    return json != null ? (Points(
	    createdBy: json['createdBy'],
      quantity: json['quantity'],
    )..fromJson(json)) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['quantity'] = this.quantity;
    data['createdBy'] = this.createdBy;
    return data;
  }
}
