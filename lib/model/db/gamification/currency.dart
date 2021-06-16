import 'package:equatable/equatable.dart';

import '../../../utils/definitions.dart';
import '../../currency_type.dart';

class Currency extends Equatable {
  final String? name;
  final CurrencyType? type;

  Currency({this.type, String? name}) : name = (type == CurrencyType.diamond ? 'points' : name);

  Currency.fromJson(Json json)
      : this(type: CurrencyType.values[json['icon']], name: json['name']);

  Currency copyWith({String? name, CurrencyType? icon}) {
    return Currency(
      name: name ?? this.name,
      type: icon ?? type,
    );
  }

  Json toJson() {
    final data = <String, dynamic>{};
    if (type != null) data['icon'] = type!.index;
    if (name != null) data['name'] = name;
    return data;
  }

  @override
  List<Object?> get props => [name, type];
}
