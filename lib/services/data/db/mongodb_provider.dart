import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/services/exception/db_exceptions.dart';
import 'package:fokus/services/remote_config_provider.dart';


class MongoDbProvider {
	Db _client;

	Future initialize() async {
		_client = new Db(await GetIt.I<RemoteConfigProvider>().dbAccessString);
		return _client.open(
			secure: true,
			timeoutConfig: TimeoutConfig(
				connectionTimeout: 8000,
				socketTimeout: 4000,
				keepAliveTime: 10 * 60
			)
		).catchError((e) => throw NoDbConnection(e));
	}

	Future update(Collection collection, SelectorBuilder selector, ModifierBuilder document) {
		return _execute(() => _client.collection(collection.name).update(selector, document, multiUpdate: true));
	}

	Future<ObjectId> insert(Collection collection, Map<String, dynamic> document) => _execute(() {
		document['_id'] ??= ObjectId();
		return _client.collection(collection.name).insert(document).then((_) => document['_id']);
	});

	Future<List<ObjectId>> insertMany(Collection collection, List<Map<String, dynamic>> documents) => _execute(() {
		documents.forEach((document) => document['_id'] ??= ObjectId());
		return _client.collection(collection.name).insertAll(documents).then((_) => documents.map((document) => document['_id'] as ObjectId).toList());
	});

	Future<int> count(Collection collection, [SelectorBuilder selector]) => _execute(() => _client.collection(collection.name).count(selector));
	Future<bool> exists(Collection collection, [SelectorBuilder selector]) async => await count(collection, selector) > 0;

	Future<T> queryOneTyped<T>(Collection collection, SelectorBuilder query, T Function(Map<String, dynamic>) constructElement) {
		return this._queryOne(collection, query).then((response) => constructElement(response));
	}

	Future<List<T>> queryTyped<T>(Collection collection, SelectorBuilder query, T Function(Map<String, dynamic>) constructElement) {
		return this._query(collection, query).then((response) => response.map((element) => constructElement(element)).toList());
	}

	Future<Map<ObjectId, T>> queryTypedMap<T>(Collection collection, SelectorBuilder query, MapEntry<ObjectId, T> Function(Map<String, dynamic>) constructEntry) {
		return this._query(collection, query).then((response) async => Map.fromEntries(response.map((element) => constructEntry(element)).toList()));
	}

	Future<Map<String, dynamic>> _queryOne(Collection collection, [SelectorBuilder selector]) => _execute(() => _client.collection(collection.name).findOne(selector));
	Future<List<Map<String, dynamic>>> _query(Collection collection, [SelectorBuilder selector]) {
	  return _execute(() async => await _client.collection(collection.name).find(selector).toList());
	}

	Future<T> _execute<T>(Future<T> Function() query) async {
		try {
			if (_client == null || _client.state != State.OPEN)
				await initialize();
			return await query();
		} on TimeoutException { // Keep alive disconnected
			await initialize();
			return query();
		} on ConnectionException { // Connection closed, try to reconnect
			await initialize();
			return query();
		} on MongoQueryTimeout { // Query timeout, retry
			return query();
		} catch(e) { // TODO Handle double MongoQueryTimeout
			if (e is NoDbConnection)
				throw e;
			throw DbQueryFailed(e);
		}
	}

	// TODO call
	void close() async => await _client.close();
}
