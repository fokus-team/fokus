import 'package:equatable/equatable.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/services/app_locales.dart';

class UICurrency extends Equatable {
	final CurrencyType? type;
	final String? title;

  UICurrency({this.type, String? title}) : title = (type == CurrencyType.diamond ? 'points' : title);
	UICurrency.fromDBModel(Currency currency) : this(type: currency.icon, title: currency.name);
	UICurrency.from(UICurrency currency) : this(type: currency.type, title: currency.title);
	
	@override
	List<Object?> get props => [type, title];

	String getName() => type == CurrencyType.diamond ? AppLocales.instance.translate(title!) : title ?? '';
}
