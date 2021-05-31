import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigProvider {
	RemoteConfig _remoteConfig = RemoteConfig.instance;

	static const String _roundSpotConfigKey = "roundSpotConfig";

	String get roundSpotConfig => _remoteConfig.getString(_roundSpotConfigKey);

	Future<RemoteConfigProvider> initialize() async {
		await _remoteConfig.fetch();
		await _remoteConfig.activate();
		return this;
	}
}
