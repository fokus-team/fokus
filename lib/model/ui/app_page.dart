enum AppPage {
	loadingPage, rolesPage,
	caregiverSignInPage, caregiverSignUpPage, childProfilesPage, childSignInPage,
	caregiverPanel, caregiverChildDashboard, caregiverPlans, caregiverPlanForm, caregiverAwards, caregiverAwardForm, caregiverBadgeForm, caregiverStatistics,
	childPanel, childAwards, childAchievements, caregiverPlanDetails, childPlanInProgress

}

extension AppPageName on AppPage {
	String get name => const {
		AppPage.loadingPage: '/loading-page',
		AppPage.rolesPage: '/roles-page',
		AppPage.caregiverSignInPage: '/auth/caregiver-sign-in-page',
		AppPage.caregiverSignUpPage: '/auth/caregiver-sign-up-page',
		AppPage.childProfilesPage: '/auth/child-profiles-page',
		AppPage.childSignInPage: '/auth/child-sign-in-page',
		AppPage.caregiverPanel: '/caregiver/panel-page',
		AppPage.caregiverChildDashboard: '/caregiver/child-dashboard',
		AppPage.caregiverPlans: '/caregiver/plans-page',
		AppPage.caregiverPlanForm: '/caregiver/plan-form-page',
		AppPage.caregiverAwards: '/caregiver/awards-page',
		AppPage.caregiverAwardForm: '/caregiver/awards-form-page',
		AppPage.caregiverBadgeForm: '/caregiver/badges-form-page',
		AppPage.caregiverStatistics: '/caregiver/statistics-page',
		AppPage.childPanel: '/child/panel-page',
		AppPage.childAwards: '/child/awards-page',
		AppPage.childAchievements: '/child/achievements-page',
		AppPage.caregiverPlanDetails: '/caregiver/plan-details',
		AppPage.childPlanInProgress: '/child/plan-in-progress-page'
	}[this];
}

enum AppFormType { create, edit }
