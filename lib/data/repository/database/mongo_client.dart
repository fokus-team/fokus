import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;

import 'package:mongo_dart/mongo_dart.dart';

class MongoClient {
	var _useLocalhost = false;
	var _localhostConfig = 'mongodb://root:pass@192.168.0.10:27017/admin';

	Db _db;

	initialize(String config) async {
		_db = new Db(_useLocalhost ? _localhostConfig : config);
		await _db.open(secure: !_useLocalhost);
	}

	// TODO call
	void close() async => await _db.close();
}
