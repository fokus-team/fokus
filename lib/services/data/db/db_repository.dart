import 'package:meta/meta.dart';

import '../../../model/db/date_span.dart';
import '../data_repository.dart';

import 'mongodb_provider.dart';

abstract class DbRepository {
	@protected
	MongoDbProvider get dbClient;
}

extension DateSpanDBUpdate on DateSpanUpdate {
	String getQuery() {
		var query = '';
		if (index >= 0)
			query += '$index.';
		return query + type.field;
	}
}
