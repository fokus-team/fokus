import 'package:fokus/data/model/db_access_params.dart';
import 'package:fokus/data/repository/database/dynamo_client.dart';
import 'package:fokus/data/repository/database/dynamo_driver.dart';

class DataRepository {
	final DynamoClient client;

	DataRepository(DbAccessConfig config) :
			client = DynamoClient(
				region: config.region,
				credentials: AwsClientCredentials(accessKey: config.accessKey, secretKey: config.secretKey)
			);

	Future testConnection() async {
		await client.get(tableName: "Test", key: {"key": "test-key"}).then((response) => print(response));
		await client.put(tableName: 'Test', item: {"key": "other-key", 'item': 'xd', 'value': 3.1415});
	}
}
