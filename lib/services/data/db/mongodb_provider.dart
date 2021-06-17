import 'dart:async';

import 'package:fokus_auth/fokus_auth.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../../model/db/collection.dart';
import '../../../utils/definitions.dart';
import '../../exception/db_exceptions.dart';


class MongoDbProvider {
	late Db _client;

	Future connect({bool dropExisting = false, bool firstTime = false}) async {
		if (firstTime && _client.isConnected) {
			if (dropExisting)
				await _client.close();
			else
				return;
		}
		_client = await MongoDBAuthenticator.authenticate(
			timeoutConfig: TimeoutConfig(
				connectionTimeout: 6000,
				socketTimeout: 3000,
				keepAliveTime: 20 * 60
			)
		).catchError((e) => throw NoDbConnection(e));
	}

	Future update(Collection collection, SelectorBuilder selector, dynamic document, {bool multiUpdate = true, bool upsert = true}) {
		return _execute(() => _client.collection(collection.name).modernUpdate(validateSelector(selector), document, multi: multiUpdate, upsert: upsert));
	}

	Future updateAll(Collection collection, List<SelectorBuilder> selectors, List<dynamic> documents, {bool multiUpdate = true, bool upsert = true}) {
		return _execute(() => _client.collection(collection.name).modernUpdateAll(selectors, documents, multi: multiUpdate, upsert: upsert));
	}

	Future<ObjectId> insert(Collection collection, Json document) => _execute(() {
		document['_id'] ??= ObjectId();
		return _execute(() => _client.collection(collection.name) .insert(document)).then((_) => document['_id']);
	});

	Future remove(Collection collection, SelectorBuilder selector) => _execute(() {
		return _execute(() => _client.collection(collection.name).remove(validateSelector(selector)));
	});

	Future<List<ObjectId>> insertMany(Collection collection, List<Json> documents) => _execute(() {
		documents.forEach((document) => document['_id'] ??= ObjectId());
		return _execute(() => _client.collection(collection.name).insertAll(documents)).then((_) => documents.map((document) => document['_id'] as ObjectId).toList());
	});

	Future<int> count(Collection collection, SelectorBuilder selector) => _execute(() => _client.collection(collection.name).count(validateSelector(selector)));
	Future<bool> exists(Collection collection, SelectorBuilder selector) async => await count(collection, selector) > 0;

	Future<T?> queryOneTyped<T>(Collection collection, SelectorBuilder query, T? Function(Json?) constructElement) {
		return _queryOne(collection, query).then((response) => constructElement(response));
	}

	Future<List<T>> queryTyped<T>(Collection collection, SelectorBuilder query, T Function(Json) constructElement) {
		return _query(collection, query).then((response) => response.map((element) => constructElement(element)).toList());
	}

	Future<Map<ObjectId, T>> queryTypedMap<T>(Collection collection, SelectorBuilder query, MapEntry<ObjectId, T> Function(Json) constructEntry) {
		return _query(collection, query).then((response) async => Map.fromEntries(response.map((element) => constructEntry(element)).toList()));
	}

	Future<Json?> _queryOne(Collection collection, SelectorBuilder selector) => _execute(() => _client.collection(collection.name).findOne(validateSelector(selector)));
	Future<List<Json>> _query(Collection collection, SelectorBuilder selector) {
	  return _execute(() async => await _client.collection(collection.name).find(validateSelector(selector)).toList());
	}

	Future<T> _execute<T>(Future<T> Function() query) async {
		doExecute({bool dropConnection = false}) async {
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
		} on NoDbConnection {
			rethrow;
		} on Exception catch(e) {
			throw DbQueryFailed(e);
		}
	}

	// TODO call
	void close() async => await _client.close();

	SelectorBuilder? validateSelector(SelectorBuilder query) => query.map.isEmpty ? null : query;
}
