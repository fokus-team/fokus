import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/model/db/user/caregiver.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/model/db/collection.dart';
import 'package:fokus/services/data/db/db_repository.dart';

mixin CurrencyDbRepository implements DbRepository {
	Future<List<Currency>?> getCurrencies(ObjectId caregiverId) {
		var query = where.eq('_id', caregiverId);
		return dbClient.queryOneTyped(Collection.user, query, (json) => Caregiver.fromJson(json)!.currencies);
	}

	Future updateCurrencies(ObjectId caregiverId, List<Currency>? currencies) {
		var document = modify;
		if (currencies != null)
			document.set('currencies', currencies.map((e) => e.toJson()).toList());
		return dbClient.update(Collection.user, where.eq('_id', caregiverId), document);
	}

}
