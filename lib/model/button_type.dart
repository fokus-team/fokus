enum ButtonType { exit, ok, retry, close }

extension TextButtonType on ButtonType {
  String get key => const {
	  ButtonType.exit: 'actions.exit',
	  ButtonType.ok: 'actions.ok',
		ButtonType.retry: 'actions.retry',
		ButtonType.close: 'actions.close'
		}[this];
}
