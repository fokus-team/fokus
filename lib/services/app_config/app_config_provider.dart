import 'package:fokus/model/app_config_entry.dart';

abstract class AppConfigProvider {
	Future initialize();

	String? getString(AppConfigEntry entry);
	void setString(AppConfigEntry entry, String value);

	List<String>? getStringList(AppConfigEntry entry);
	void setStringList(AppConfigEntry entry, List<String> list);

	bool? getBool(AppConfigEntry entry);
	void setBool(AppConfigEntry entry, bool value);

	void remove(AppConfigEntry entry);

	bool containsEntry(AppConfigEntry entry);
}
