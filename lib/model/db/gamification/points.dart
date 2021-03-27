// @dart = 2.10
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Points extends Currency {
	ObjectId createdBy;
  int quantity;

	Points.fromUICurrency(UICurrency currency, int quantity, {ObjectId creator}) :
				this._(name: currency.title, icon: currency.type, quantity: quantity, createdBy: creator);
	Points.fromUIPoints(UIPoints points) :
				this._(name: points.title, icon: points.type, quantity: points.quantity, createdBy: points.createdBy);
  Points._({String name, CurrencyType icon, this.createdBy, this.quantity}) : super(name : name, icon: icon);

  factory Points.fromJson(Map<String, dynamic> json) {
    return json != null ? (Points._(
	    createdBy: json['createdBy'],
      quantity: json['quantity'],
    )..fromJson(json)) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (this.quantity != null)
	    data['quantity'] = this.quantity;
    if (createdBy != null)
      data['createdBy'] = this.createdBy;
    return data;
  }
}
