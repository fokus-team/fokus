enum CurrencyType { diamond, emerald, ruby, amethyst }

extension CurrencyTypeName on CurrencyType {
	String get name => const {
		CurrencyType.diamond: 'diamond',
		CurrencyType.emerald: 'emerald',
		CurrencyType.ruby: 'ruby',
		CurrencyType.amethyst: 'amethyst',
	}[this];
}
