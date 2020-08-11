enum AppConfigEntry {
	someEntry
}

extension AppConfigEntryKey on AppConfigEntry {
	String get key => const {
	}[this];
}
