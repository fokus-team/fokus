import 'package:fokus/model/db/collection.dart';

import 'package:mongo_dart/mongo_dart.dart';

class MongoDbProvider {
	var _useLocalhost = false;
	var _localhostConfig = 'mongodb://root:pass@192.168.0.10:27017/admin';

	Db _db;

	Future initialize(String config) async {
		_db = new Db(_useLocalhost ? _localhostConfig : config);
		return _db.open(secure: !_useLocalhost);
	}

	Future<Map<String, dynamic>> queryOne(Collection collection, [SelectorBuilder selector]) => _db.collection(collection.name).findOne(selector);
	Future<Stream<Map<String, dynamic>>> query(Collection collection, [SelectorBuilder selector]) async => _db.collection(collection.name).find(selector);

	Future<int> count(Collection collection, [SelectorBuilder selector]) async => _db.collection(collection.name).count(selector);
	Future<bool> exists(Collection collection, [SelectorBuilder selector]) async => await count(collection, selector) > 0;


	Future<T> queryOneTyped<T>(Collection collection, SelectorBuilder query, T Function(Map<String, dynamic>) constructElement) {
		return this.queryOne(collection, query).then((response) => constructElement(response));
	}


	Future<List<T>> queryTyped<T>(Collection collection, SelectorBuilder query, T Function(Map<String, dynamic>) constructElement) {
		return this.query(collection, query).then((response) => response.map((element) => constructElement(element)).toList());
	}

	Future<Map<ObjectId, T>> queryTypedMap<T>(Collection collection, SelectorBuilder query, MapEntry<ObjectId, T> Function(Map<String, dynamic>) constructEntry) {
		return this.query(collection, query).then((response) async => Map.fromEntries(await response.map((element) => constructEntry(element)).toList()));
	}

	// TODO call
	void close() async => await _db.close();
}
