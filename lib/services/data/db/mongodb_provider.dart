import 'dart:async';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:fokus/model/db/collection.dart';
import 'package:fokus/services/exception/db_exceptions.dart';


class MongoDbProvider {
	Db _client;

	Future connect({bool dropExisting = false}) async {
		if (_client != null && _client.isConnected) {
			if (dropExisting)
				await _client.close();
			else
				return;
		}
		_client = await MongoDBAuthenticator.authenticate(
			timeoutConfig: TimeoutConfig(
				connectionTimeout: 6000,
				socketTimeout: 4000,
				keepAliveTime: 20 * 60
			)
		).catchError((e) => throw NoDbConnection(e));
	}

	Future update(Collection collection, dynamic selector, dynamic document, {bool multiUpdate = true, bool upsert = true}) {
		return _execute(() => _client.collection(collection.name).update(selector, document, multiUpdate: multiUpdate, upsert: upsert));
	}

	Future updateAll(Collection collection, List<SelectorBuilder> selectors, List<dynamic> documents, {bool multiUpdate = true, bool upsert = true}) {
		return _execute(() => _client.collection(collection.name).updateAll(selectors, documents, multiUpdate: multiUpdate, upsert: upsert));
	}

	Future<ObjectId> insert(Collection collection, Map<String, dynamic> document) => _execute(() {
		document['_id'] ??= ObjectId();
		return _execute(() => _client.collection(collection.name) .insert(document)).then((_) => document['_id']);
	});

	Future remove(Collection collection, SelectorBuilder selector) => _execute(() {
		return _execute(() => _client.collection(collection.name).remove(selector));
	});

	Future<List<ObjectId>> insertMany(Collection collection, List<Map<String, dynamic>> documents) => _execute(() {
		documents.forEach((document) => document['_id'] ??= ObjectId());
		return _execute(() => _client.collection(collection.name).insertAll(documents)).then((_) => documents.map((document) => document['_id'] as ObjectId).toList());
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
		var doExecute = ({bool dropConnection = false}) async {
			await connect(dropExisting: dropConnection);
			return await query();
		};
		try {
			return await doExecute();
		} on ConnectionException { // Connection closed, try to reconnect
			return await doExecute();
		} on TimeoutException { // Keep alive disconnected
			return await doExecute();
		} on MongoQueryTimeout { // Query timeout, retry
			return await doExecute(dropConnection: true);
		} catch(e) {
			if (e is NoDbConnection)
				throw e;
			throw DbQueryFailed(e);
		}
	}

	// TODO call
	void close() async => await _client.close();
}
