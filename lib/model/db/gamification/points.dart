import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/utils/definitions.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Points extends Currency {
  final ObjectId? createdBy;
  final int? quantity;

  Points.fromCurrency({required Currency currency, this.createdBy, this.quantity})
		  : super(name: currency.name, type: currency.type);
  Points({String? name, CurrencyType? icon, this.createdBy, this.quantity})
		  : super(name: name, type: icon);

  Points copyWith({
    String? name,
    CurrencyType? icon,
    ObjectId? createdBy,
    int? quantity,
  }) {
    return Points(
      name: name ?? this.name,
      icon: icon ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      quantity: quantity ?? this.quantity,
    );
  }

  Points.fromJson(Json json)
      : createdBy = json['createdBy'],
        quantity = json['quantity'],
        super.fromJson(json);

  Json toJson() {
    final Json data = super.toJson();
    if (this.quantity != null) data['quantity'] = this.quantity;
    if (createdBy != null) data['createdBy'] = this.createdBy;
    return data;
  }

  @override
  List<Object?> get props => super.props..addAll([createdBy, quantity]);
}
