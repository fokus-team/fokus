enum AppPage {
	// Shared
	loadingPage,
	rolesPage,
	notificationsPage,
	settingsPage,
	// Auth
	caregiverSignInPage,
	caregiverSignUpPage,
	childProfilesPage,
	childSignInPage,
	// Caregiver
	caregiverPanel,
	caregiverChildDashboard,
	caregiverCalendar,
	caregiverPlans,
	caregiverPlanForm,
	caregiverPlanDetails,
	caregiverAwards,
	caregiverRewardForm,
	caregiverBadgeForm,
	caregiverStatistics,
	caregiverRatingPage,
	caregiverCurrencies,
	// Child
	childPanel,
	childCalendar,
	childRewards,
	childAchievements,
	childPlanInProgress,
	childTaskInProgress
}

extension AppPageName on AppPage {
	String get name => const {
		AppPage.loadingPage: '/loading-page',
		AppPage.rolesPage: '/roles-page',
    AppPage.notificationsPage: '/notifications-page',
    AppPage.settingsPage: '/settings-page',
		AppPage.caregiverSignInPage: '/auth/caregiver-sign-in-page',
		AppPage.caregiverSignUpPage: '/auth/caregiver-sign-up-page',
		AppPage.childProfilesPage: '/auth/child-profiles-page',
		AppPage.childSignInPage: '/auth/child-sign-in-page',
		AppPage.caregiverPanel: '/caregiver/panel-page',
		AppPage.caregiverChildDashboard: '/caregiver/child-dashboard',
		AppPage.caregiverCalendar: '/caregiver/calendar-page',
		AppPage.caregiverPlans: '/caregiver/plans-page',
		AppPage.caregiverPlanForm: '/caregiver/plan-form-page',
		AppPage.caregiverPlanDetails: '/caregiver/plan-details',
		AppPage.caregiverAwards: '/caregiver/awards-page',
		AppPage.caregiverRewardForm: '/caregiver/rewards-form-page',
		AppPage.caregiverBadgeForm: '/caregiver/badges-form-page',
		AppPage.caregiverStatistics: '/caregiver/statistics-page',
		AppPage.caregiverRatingPage: '/caregiver/rating-page',
		AppPage.caregiverCurrencies: '/caregiver/currencies-page',
		AppPage.childPanel: '/child/panel-page',
		AppPage.childCalendar: '/child/calendar-page',
		AppPage.childRewards: '/child/rewards-page',
		AppPage.childAchievements: '/child/achievements-page',
		AppPage.childPlanInProgress: '/child/plan-in-progress-page',
		AppPage.childTaskInProgress: '/child/task-in-progress-page'
	}[this];
}

enum AppFormType { create, edit }
