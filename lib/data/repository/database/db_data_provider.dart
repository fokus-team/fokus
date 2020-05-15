import 'package:fokus/data/model/db_access_params.dart';
import 'package:fokus/data/repository/database/dynamo_client.dart';
import 'package:fokus/data/repository/database/dynamo_driver.dart';

class DbProvider {
	final DynamoClient client;

  DbProvider(DbAccessConfig config) :
		  client = DynamoClient(
			  region: config.region,
			  credentials: AwsClientCredentials(accessKey: config.accessKey, secretKey: config.secretKey)
		  );

  void testConnection() {
  	client.get(tableName: "Test", key: {"key": "test-key"}).then((response) {
		  print(response.item);
	  });

  }
}
