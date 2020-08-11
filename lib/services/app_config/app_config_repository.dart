import 'package:fokus/model/app_config_entry.dart';
import 'package:fokus/services/app_config/app_config_provider.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AppConfigRepository {
	AppConfigProvider _settingsProvider;

	AppConfigRepository(this._settingsProvider);

	Future<AppConfigRepository> initialize() async {
		await _settingsProvider.initialize();
		return this;
	}
}
