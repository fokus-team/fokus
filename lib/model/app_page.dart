enum AppPage {
	loadingPage, rolesPage, notificationsPage,
	caregiverPanel, caregiverPlans, caregiverAwards, caregiverStatistics,
	childPanel, childAwards, childAchievements
}

extension AppPageName on AppPage {
	String get name => const {
		AppPage.loadingPage: '/loading-page',
		AppPage.rolesPage: '/roles-page',
    AppPage.notificationsPage: '/notifications-page',
		AppPage.caregiverPanel: '/caregiver/panel-page',
		AppPage.caregiverPlans: '/caregiver/plans-page',
		AppPage.caregiverAwards: '/caregiver/awards-page',
		AppPage.caregiverStatistics: '/caregiver/statistics-page',
		AppPage.childPanel: '/child/panel-page',
		AppPage.childAwards: '/child/awards-page',
		AppPage.childAchievements: '/child/achievements-page',
	}[this];
}
