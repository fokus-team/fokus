enum ButtonType { EXIT, RETRY, CLOSE }

extension TextButtonType on ButtonType {
  String get key => const {
		ButtonType.EXIT: 'actions.exit', 
		ButtonType.RETRY: 'actions.retry',
		ButtonType.CLOSE: 'actions.close'
		}[this];
}
