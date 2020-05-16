enum ButtonType {
	EXIT, RETRY
}

extension TextButtonType on ButtonType {
	String get key => const {
		ButtonType.EXIT: 'button.exit',
		ButtonType.RETRY: 'button.retry'
	}[this];
}
