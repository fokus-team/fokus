import 'package:meta/meta.dart';

import 'mongodb_provider.dart';

abstract class DbRepository {
	@protected
	MongoDbProvider get dbClient;
}
