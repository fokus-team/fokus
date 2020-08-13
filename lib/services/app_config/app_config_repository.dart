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

	ObjectId getSignedInChild() => _settingsProvider.containsEntry(AppConfigEntry.signedInChild) ? ObjectId.parse(_settingsProvider.getString(AppConfigEntry.signedInChild)) : null;

	void signInChild(ObjectId userId) => _settingsProvider.setString(AppConfigEntry.signedInChild, userId.toHexString());

	void signOutChild() => _settingsProvider.remove(AppConfigEntry.signedInChild);

	List<ObjectId> getSavedChildProfiles() {
	  if (_settingsProvider.containsEntry(AppConfigEntry.savedChildProfiles))
	    return _settingsProvider.getStringList(AppConfigEntry.savedChildProfiles).map((id) => ObjectId.parse(id));
	  return null;
	}

	void saveChildProfile(ObjectId userId) {
		var savedList = _settingsProvider.getStringList(AppConfigEntry.savedChildProfiles) ?? [];
		if (!savedList.contains(userId)) {
			savedList.add(userId.toHexString());
			_settingsProvider.setStringList(AppConfigEntry.savedChildProfiles, savedList);
		}
	}

	void removeSavedChildProfile(ObjectId userId) {
		var newList = _settingsProvider.getStringList(AppConfigEntry.savedChildProfiles).where((element) => element != userId.toHexString());
		_settingsProvider.setStringList(AppConfigEntry.savedChildProfiles, newList);
	}
}
