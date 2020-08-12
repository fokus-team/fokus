enum AppConfigEntry {
	savedChildProfiles, signedInChild
}

extension AppConfigEntryKey on AppConfigEntry {
	String get key => const {
		AppConfigEntry.savedChildProfiles: 'savedChildProfiles',
		AppConfigEntry.signedInChild: 'signedInChild'
	}[this];
}
