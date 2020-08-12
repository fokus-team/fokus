import 'package:meta/meta.dart';

import 'package:fokus/model/db/date_span.dart';
import 'package:fokus/services/data/data_repository.dart';

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
