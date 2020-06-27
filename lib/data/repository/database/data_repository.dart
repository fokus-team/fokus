import 'package:fokus/data/repository/database/mongo_client.dart';

class DataRepository {
	final MongoClient client = MongoClient();

	void initialize(String config) async {
		await client.initialize(config);
	}
}
