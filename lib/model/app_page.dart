enum AppPage {
	loadingPage, rolesPage,
	caregiverPanel, caregiverPlans, caregiverAwards, caregiverStatistics,
	childPanel, childAwards, childAchievements, childPlanInProgress
}

extension AppPageName on AppPage {
	String get name => const {
		AppPage.loadingPage: '/loading-page',
		AppPage.rolesPage: '/roles-page',
		AppPage.caregiverPanel: '/caregiver/panel-page',
		AppPage.caregiverPlans: '/caregiver/plans-page',
		AppPage.caregiverAwards: '/caregiver/awards-page',
		AppPage.caregiverStatistics: '/caregiver/statistics-page',
		AppPage.childPanel: '/child/panel-page',
		AppPage.childAwards: '/child/awards-page',
		AppPage.childAchievements: '/child/achievements-page',
		AppPage.childPlanInProgress: '/child/plan-in-progress-page'
	}[this];
}
