import 'package:mongo_dart/mongo_dart.dart';
import '../../../model/db/gamification/currency.dart';

abstract class CurrencyRepository {
	Future updateCurrencies(ObjectId caregiverId, List<Currency>? currencies);
}
