import 'package:fokus/model/app_config_entry.dart';

abstract class AppConfigProvider {
	Future initialize();

	String getString(AppConfigEntry entry);
	void setString(AppConfigEntry entry, String value);

	List<String> getStringList(AppConfigEntry entry);
	void setStringList(AppConfigEntry entry, List<String> list);

	void remove(AppConfigEntry entry);

	bool containsEntry(AppConfigEntry entry);
	Set<AppConfigEntry> getEntries();
}
