import 'package:mongo_dart/mongo_dart.dart';

import '../../../utils/definitions.dart';
import '../../currency_type.dart';
import 'currency.dart';

class Points extends Currency {
  final ObjectId? createdBy;
  final int? quantity;

  Points.fromCurrency({required Currency currency, this.createdBy, this.quantity})
		  : super(name: currency.name, type: currency.type);
  Points({String? name, CurrencyType? icon, this.createdBy, this.quantity})
		  : super(name: name, type: icon);

  @override
  Points copyWith({
    String? name,
    CurrencyType? icon,
    ObjectId? createdBy,
    int? quantity,
  }) {
    return Points(
      name: name ?? this.name,
      icon: icon ?? type,
      createdBy: createdBy ?? this.createdBy,
      quantity: quantity ?? this.quantity,
    );
  }

  Points.fromJson(Json json)
      : createdBy = json['createdBy'],
        quantity = json['quantity'],
        super.fromJson(json);

  @override
  Json toJson() {
    final data = super.toJson();
    if (quantity != null) data['quantity'] = quantity;
    if (createdBy != null) data['createdBy'] = createdBy;
    return data;
  }

  @override
  List<Object?> get props => super.props..addAll([createdBy, quantity]);
}
