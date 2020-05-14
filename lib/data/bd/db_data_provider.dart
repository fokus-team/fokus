import 'package:fokus/data/bd/dynamo_client.dart';

class DbProvider {
	final DynamoClient client;

  DbProvider() : client = DynamoClient();
}
