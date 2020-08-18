import 'package:equatable/equatable.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UIPlanCurrency extends Equatable {
	final ObjectId id;
	final CurrencyType type;
	final String title;

  UIPlanCurrency({
		this.id,
		this.type,
		this.title
	});
	
	@override
	List<Object> get props => [id, type, title];

}
