import 'package:fokus/model/currency_type.dart';
import 'package:fokus/utils/definitions.dart';
import 'package:meta/meta.dart';

class Currency {
	String? name;
	CurrencyType? icon;

	Currency({this.icon, this.name});

	static Currency? fromJson(Json? json) =>
			json != null ? (Currency()..assignFromJson(json)) : null;

	@protected
	void assignFromJson(Json json) {
		icon = CurrencyType.values[json['icon']];
		name = json['name'];
	}

	Json toJson() {
		final Json data = new Json();
		if (this.icon != null)
      data['icon'] = this.icon!.index;
		if (this.name != null)
      data['name'] = this.name;
		return data;
	}
}
