enum AppPage {
	loadingPage, rolesPage, caregiverPanel, childPanel
}

extension AppPageName on AppPage {
	String get name => const {
		AppPage.loadingPage: '/loading-page',
		AppPage.rolesPage: '/roles-page',
		AppPage.caregiverPanel: '/caregiver-panel-page',
		AppPage.childPanel: '/child-panel-page',
	}[this];
}
