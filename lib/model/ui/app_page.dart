enum AppPage {
	loadingPage, rolesPage,
	caregiverLoginPage, caregiverSignInPage,
	caregiverPanel, caregiverPlans, caregiverAwards, caregiverStatistics,
	childPanel, childAwards, childAchievements
}

extension AppPageName on AppPage {
	String get name => const {
		AppPage.loadingPage: '/loading-page',
		AppPage.rolesPage: '/roles-page',
		AppPage.caregiverLoginPage: '/auth/caregiver-login-page',
		AppPage.caregiverSignInPage: '/auth/caregiver-sign-in-page',
		AppPage.caregiverPanel: '/caregiver/panel-page',
		AppPage.caregiverPlans: '/caregiver/plans-page',
		AppPage.caregiverAwards: '/caregiver/awards-page',
		AppPage.caregiverStatistics: '/caregiver/statistics-page',
		AppPage.childPanel: '/child/panel-page',
		AppPage.childAwards: '/child/awards-page',
		AppPage.childAchievements: '/child/achievements-page',
	}[this];
}
