import 'package:mongo_dart/mongo_dart.dart';

import '../../../model/currency_type.dart';
import '../../../model/db/collection.dart';
import '../../../model/db/gamification/currency.dart';
import '../db/db_repository.dart';

mixin CurrencyDbRepository implements DbRepository {
	Future updateCurrencies(ObjectId caregiverId, List<Currency>? currencies) {
		var document = modify;
		if (currencies != null)
			document.set('currencies', currencies.where((c) => c.type != CurrencyType.diamond).map((e) => e.toJson()).toList());
		return dbClient.update(Collection.user, where.eq('_id', caregiverId), document);
	}
}
