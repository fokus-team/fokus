import 'package:fokus/model/app_config_entry.dart';

abstract class AppConfigProvider {
	Future initialize();

	String getString(AppConfigEntry entry);
	void setString(AppConfigEntry entry, String value);

	void remove(AppConfigEntry entry);

	bool containsEntry(AppConfigEntry entry);
	Set<AppConfigEntry> getEntries();
}
