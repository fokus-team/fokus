enum AppConfigEntry {
	savedChildProfiles, signedInChild, isAnyTaskActive
}

extension AppConfigEntryKey on AppConfigEntry {
	String get key => const {
		AppConfigEntry.savedChildProfiles: 'savedChildProfiles',
		AppConfigEntry.signedInChild: 'signedInChild',
		AppConfigEntry.isAnyTaskActive: 'isAnyTaskActive'
	}[this];
}
