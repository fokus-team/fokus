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

	List<ObjectId> getSavedChildProfiles() {
	  if (_settingsProvider.containsEntry(AppConfigEntry.savedChildProfiles))
	    return _settingsProvider.getStringList(AppConfigEntry.savedChildProfiles).map((id) => ObjectId.parse(id));
	  return null;
	}

	void saveChildProfile(ObjectId userId) {
		var newList = _settingsProvider.getStringList(AppConfigEntry.savedChildProfiles)..add(userId.toHexString());
	  _settingsProvider.setStringList(AppConfigEntry.savedChildProfiles, newList);
	}

	void removeSavedChildProfile(ObjectId userId) {
		var newList = _settingsProvider.getStringList(AppConfigEntry.savedChildProfiles).where((element) => element != userId.toHexString());
		_settingsProvider.setStringList(AppConfigEntry.savedChildProfiles, newList);
	}
}
