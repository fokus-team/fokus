enum AppPopup {
	reward,
	badge,
	help,
	aboutApp,
	nameEdit,
	passwordChange,
	accountDelete,
	addFriend,
	currencyEdit,
	general,
	formExit,
}

const String _prefix = '/dialogs';

extension AppPopupName on AppPopup {
	String get name => const {
		AppPopup.reward: '$_prefix/reward',
		AppPopup.badge: '$_prefix/badge',
		AppPopup.help: '$_prefix/help',
		AppPopup.aboutApp: '$_prefix/about-app',
		AppPopup.nameEdit: '$_prefix/name-edit',
		AppPopup.passwordChange: '$_prefix/password-change',
		AppPopup.accountDelete: '$_prefix/account-delete',
		AppPopup.addFriend: '$_prefix/add-friend',
		AppPopup.currencyEdit: '$_prefix/currency-edit',
		AppPopup.general: '$_prefix/general',
		AppPopup.formExit: '$_prefix/form-exit',
	}[this];
}
