import 'package:mongo_dart/mongo_dart.dart';
import 'package:fokus/model/db/gamification/currency.dart';

abstract class CurrencyRepository {
	Future<List<Currency>?> getCurrencies(ObjectId caregiverId);
	Future updateCurrencies(ObjectId caregiverId, List<Currency>? currencies);
}
