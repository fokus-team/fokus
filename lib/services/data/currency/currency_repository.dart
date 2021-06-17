import 'package:mongo_dart/mongo_dart.dart';
import '../../../model/db/gamification/currency.dart';

// ignore: one_member_abstracts
abstract class CurrencyRepository {
	Future updateCurrencies(ObjectId caregiverId, List<Currency>? currencies);
}
