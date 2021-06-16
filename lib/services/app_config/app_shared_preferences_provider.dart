import 'package:shared_preferences/shared_preferences.dart';

import '../../model/app_config_entry.dart';
import 'app_config_provider.dart';

class AppSharedPreferencesProvider implements AppConfigProvider {
	late SharedPreferences _preferences;

	@override
	Future initialize() async => _preferences = await SharedPreferences.getInstance();

	@override
	String? getString(AppConfigEntry entry) => _preferences.getString(entry.key);

	@override
	void remove(AppConfigEntry entry) => _preferences.remove(entry.key);

	@override
	void setString(AppConfigEntry entry, String value) => _preferences.setString(entry.key, value);

  @override
  bool containsEntry(AppConfigEntry entry) => _preferences.containsKey(entry.key);

  @override
  List<String>? getStringList(AppConfigEntry entry) => _preferences.getStringList(entry.key);

  @override
  void setStringList(AppConfigEntry entry, List<String> list) => _preferences.setStringList(entry.key, list);

  @override
  bool? getBool(AppConfigEntry entry) => _preferences.getBool(entry.key);

  @override
  void setBool(AppConfigEntry entry, bool value) => _preferences.setBool(entry.key, value);
}
