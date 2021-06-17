enum PasswordChangeType {
	change, reset
}

extension PasswordChangeTypeText on PasswordChangeType {
	String get key => const {
		PasswordChangeType.change: 'passwordChanged',
		PasswordChangeType.reset: 'passwordReset'
	}[this]!;
}

