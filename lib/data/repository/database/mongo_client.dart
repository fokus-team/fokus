import 'package:fokus/data/model/collection.dart';

import 'package:mongo_dart/mongo_dart.dart';

class MongoClient {
	var _useLocalhost = false;
	var _localhostConfig = 'mongodb://root:pass@192.168.0.10:27017/admin';

	Db _db;

	Future initialize(String config) async {
		_db = new Db(_useLocalhost ? _localhostConfig : config);
		return _db.open(secure: !_useLocalhost);
	}

	Future<Map<String, dynamic>> query(Collection collection) async {
		return _db.collection(collection.name).findOne();
	}

	// TODO call
	void close() async => await _db.close();
}
