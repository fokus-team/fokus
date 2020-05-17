import 'dart:collection';

import 'package:fokus/exception/db_limit_exceeded_exception.dart';
import 'package:fokus/utils/dynamo_type_mapper.dart';
import 'dynamo_driver.dart';

class DynamoClient {
	final DynamoDB _dynamoDB;

	DynamoClient({@required String region, AwsClientCredentials credentials, String endpointUrl, Client client})
			: _dynamoDB = DynamoDB(region: region, credentials: credentials, endpointUrl: endpointUrl, client: client);

	Future<Map<String, dynamic>> get({@required String tableName, @required int key, List<String> attributesSubset}) async {
		final GetItemOutput getItemOutput = await _executeQuery(() => _dynamoDB.getItem(
			key: key.asAttributeKey(),
			tableName: tableName,
			projectionExpression: attributesSubset != null ? attributesSubset.join(', ') : null)
		);
		return getItemOutput.item.asJson();
	}

	Future<List<Map<String, dynamic>>> query({@required String tableName, String paramFilter,
		Map<String, String> nameMap, Map<String, dynamic> valueMap, List<String> attributesSubset}) async {
		final ScanOutput getItemOutput = await _executeQuery(() => _dynamoDB.query(
			filterExpression: paramFilter,
			tableName: tableName,
			expressionAttributeNames: nameMap,
			expressionAttributeValues: valueMap.asAttributeValue(),
			projectionExpression: attributesSubset != null ? attributesSubset.join(', ') : null)
		);
		return getItemOutput.items.map((item) => item.asJson()).toList();
	}

	Future put({@required String tableName, @required Map<String, dynamic> item, String condition}) async {
		await _executeQuery(() => _dynamoDB.putItem(
			item: item.asAttributeValue(),
			tableName: tableName,
			conditionExpression: condition)
		);
	}

	Future delete({@required String tableName, @required int key, String condition}) async {
		await _executeQuery(() => _dynamoDB.deleteItem(
			key: key.asAttributeKey(),
			tableName: tableName,
			conditionExpression: condition)
		);
	}

	dynamic _executeQuery(Future<dynamic> Function() query) async {
		try {
			return await query();
		} catch(e) {
			if (e is RequestLimitExceeded || e is ProvisionedThroughputExceededException)
				throw DbLimitsExceededException(e);
			throw e;
		}
	}
}
