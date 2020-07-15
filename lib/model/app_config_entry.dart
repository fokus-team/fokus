enum AppConfigEntry {
	lastUser
}

extension AppConfigEntryKey on AppConfigEntry {
	String get key => const {
		AppConfigEntry.lastUser: 'lastUser',
	}[this];
}
