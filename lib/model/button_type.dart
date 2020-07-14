enum ButtonType { exit, retry, close }

extension TextButtonType on ButtonType {
  String get key => const {
		ButtonType.exit: 'actions.exit',
		ButtonType.retry: 'actions.retry',
		ButtonType.close: 'actions.close'
		}[this];
}
