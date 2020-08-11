import 'package:logging/logging.dart';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'exception/config_fetch_failed.dart';

class RemoteConfigProvider {
	final Logger _logger = Logger('RemoteConfigProvider');
	RemoteConfig _remoteConfig;
	
	String _dbAccessString;
	String get dbAccessString => _dbAccessString;

	static const String _dbConfigKey = "db_access_string";

	Future initialize() async {
		_remoteConfig = await RemoteConfig.instance;
		await _remoteConfig.fetch();
		await _remoteConfig.activateFetched();

		var dbConfig = _remoteConfig.getString(_dbConfigKey);
		if (dbConfig == '') {
			_logger.warning('Could not retrieve the database configuration');
			throw ConfigFetchFailed();
		}
		_dbAccessString = dbConfig;
	}
}
