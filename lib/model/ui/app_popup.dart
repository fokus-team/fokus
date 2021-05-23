enum AppPopup {
	rewardDialog,
}

extension AppPopupName on AppPopup {
	String get name => const {
		AppPopup.rewardDialog: '/reward-dialog'
	}[this];
}
