import 'package:fokus/model/currency_type.dart';
import 'package:meta/meta.dart';

class Currency {
	String? name;
	CurrencyType? icon;

	Currency({this.icon, this.name});

	static Currency? fromJson(Map<String, dynamic>? json) =>
			json != null ? (Currency()..assignFromJson(json)) : null;

	@protected
	void assignFromJson(Map<String, dynamic> json) {
		icon = CurrencyType.values[json['icon']];
		name = json['name'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.icon != null)
      data['icon'] = this.icon!.index;
		if (this.name != null)
      data['name'] = this.name;
		return data;
	}
}
