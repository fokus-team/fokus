enum AppPage {
	// Shared
	loadingPage,
	rolesPage,
	notificationsPage,
	// Auth
	caregiverSignInPage,
	caregiverSignUpPage,
	childProfilesPage,
	childSignInPage,
	// Caregiver
	caregiverPanel,
	caregiverChildDashboard,
	caregiverPlans,
	caregiverPlanForm,
	caregiverPlanDetails,
	caregiverAwards,
	caregiverAwardForm,
	caregiverBadgeForm,
	caregiverStatistics,
	// Child
	childPanel,
	childAwards,
	childAchievements,
	childPlanInProgress,
	childTaskInProgress
}

extension AppPageName on AppPage {
	String get name => const {
		AppPage.loadingPage: '/loading-page',
		AppPage.rolesPage: '/roles-page',
    AppPage.notificationsPage: '/notifications-page',
		AppPage.caregiverSignInPage: '/auth/caregiver-sign-in-page',
		AppPage.caregiverSignUpPage: '/auth/caregiver-sign-up-page',
		AppPage.childProfilesPage: '/auth/child-profiles-page',
		AppPage.childSignInPage: '/auth/child-sign-in-page',
		AppPage.caregiverPanel: '/caregiver/panel-page',
		AppPage.caregiverChildDashboard: '/caregiver/child-dashboard',
		AppPage.caregiverPlans: '/caregiver/plans-page',
		AppPage.caregiverPlanForm: '/caregiver/plan-form-page',
		AppPage.caregiverPlanDetails: '/caregiver/plan-details',
		AppPage.caregiverAwards: '/caregiver/awards-page',
		AppPage.caregiverAwardForm: '/caregiver/awards-form-page',
		AppPage.caregiverBadgeForm: '/caregiver/badges-form-page',
		AppPage.caregiverStatistics: '/caregiver/statistics-page',
		AppPage.childPanel: '/child/panel-page',
		AppPage.childAwards: '/child/awards-page',
		AppPage.childAchievements: '/child/achievements-page',
		AppPage.childPlanInProgress: '/child/plan-in-progress-page',
		AppPage.childTaskInProgress: '/child/task-in-progress-page'
	}[this];
}

enum AppFormType { create, edit }
