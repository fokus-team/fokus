enum AppConfigEntry {
	savedChildProfiles
}

extension AppConfigEntryKey on AppConfigEntry {
	String get key => const {
		AppConfigEntry.savedChildProfiles: 'savedChildProfiles'
	}[this];
}
