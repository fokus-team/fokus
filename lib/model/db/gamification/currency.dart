import 'package:equatable/equatable.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/utils/definitions.dart';

class Currency extends Equatable {
  final String? name;
  final CurrencyType? type;

  Currency({this.type, String? name}) : name = (type == CurrencyType.diamond ? 'points' : name);

  Currency.fromJson(Json json)
      : this(type: CurrencyType.values[json['icon']], name: json['name']);

  Currency copyWith({String? name, CurrencyType? icon}) {
    return Currency(
      name: name ?? this.name,
      type: icon ?? this.type,
    );
  }

  Json toJson() {
    final Json data = new Json();
    if (this.type != null) data['icon'] = this.type!.index;
    if (this.name != null) data['name'] = this.name;
    return data;
  }

  @override
  List<Object?> get props => [name, type];
}
