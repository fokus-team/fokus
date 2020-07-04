import 'package:fokus/data/model/collection.dart';
import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/data/repository/database/mongo_client.dart';

class DataRepository {
	final MongoClient client = MongoClient();

	Future initialize(String config) async {
		return client.initialize(config);
	}

	Future<Caregiver> fetchUser() async {
		return client.query(Collection.USER).then((response) => Caregiver.fromJson(response));
	}
}
