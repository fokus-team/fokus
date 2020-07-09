import 'package:fokus/data/model/collection.dart';
import 'package:fokus/data/model/user/caregiver.dart';
import 'package:fokus/data/repository/database/mongo_client.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DataRepository {
	final MongoClient client = MongoClient();

	Future<DataRepository> initialize(String config) async {
		await client.initialize(config);
		return this;
	}

	Future<Caregiver> fetchUser(ObjectId id) async {
		return client.query(Collection.user, where.eq('_id', id)).then((response) => Caregiver.fromJson(response));
	}
}
