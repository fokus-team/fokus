enum AppConfigEntry {
	savedChildProfiles, signedInChild, userLanguage
}

extension AppConfigEntryKey on AppConfigEntry {
	String get key => const {
		AppConfigEntry.savedChildProfiles: 'savedChildProfiles',
		AppConfigEntry.signedInChild: 'signedInChild',
		AppConfigEntry.userLanguage: 'userLanguage'
	}[this];
}
