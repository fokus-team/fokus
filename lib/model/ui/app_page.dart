enum AppPage {
	// Shared
	loadingPage,
	errorPage,
	rolesPage,
	notificationsPage,
	settingsPage,
	planDetails,
	planInstanceDetails,
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
	caregiverAwards,
	caregiverRewardForm,
	caregiverBadgeForm,
	caregiverRatingPage,
	caregiverCurrencies,
	caregiverFriendPlans,
	// Child
	childPanel,
	childCalendar,
	childRewards,
	childAchievements,
	childTaskInProgress
}

extension AppPageName on AppPage {
	String get name => const {
		AppPage.loadingPage: '/loading-page',
		AppPage.errorPage: '/error-page',
		AppPage.rolesPage: '/roles-page',
    AppPage.notificationsPage: '/notifications-page',
    AppPage.settingsPage: '/settings-page',
		AppPage.planInstanceDetails: '/plan-instance-details-page',
		AppPage.planDetails: '/plan-details-page',

		AppPage.caregiverSignInPage: '/auth/caregiver-sign-in-page',
		AppPage.caregiverSignUpPage: '/auth/caregiver-sign-up-page',
		AppPage.childProfilesPage: '/auth/child-profiles-page',
		AppPage.childSignInPage: '/auth/child-sign-in-page',
		AppPage.caregiverPanel: '/caregiver/panel-page',
		AppPage.caregiverChildDashboard: '/caregiver/child-dashboard',
		AppPage.caregiverCalendar: '/caregiver/calendar-page',
		AppPage.caregiverPlans: '/caregiver/plans-page',
		AppPage.caregiverPlanForm: '/caregiver/plan-form-page',
		AppPage.caregiverFriendPlans: '/caregiver/friend-plans-page',

		AppPage.caregiverAwards: '/caregiver/awards-page',
		AppPage.caregiverRewardForm: '/caregiver/rewards-form-page',
		AppPage.caregiverBadgeForm: '/caregiver/badges-form-page',
		AppPage.caregiverRatingPage: '/caregiver/rating-page',
		AppPage.caregiverCurrencies: '/caregiver/currencies-page',

		AppPage.childPanel: '/child/panel-page',
		AppPage.childCalendar: '/child/calendar-page',
		AppPage.childRewards: '/child/rewards-page',
		AppPage.childAchievements: '/child/achievements-page',
		AppPage.childTaskInProgress: '/child/task-in-progress-page'
	}[this];
}


enum AppPageSection {
	login, caregiver, child
}
