enum RepeatabilityType { once, weekly, monthly }

extension RepeatabilityTypeName on RepeatabilityType {
	String get name => const {
		RepeatabilityType.once: 'once',
		RepeatabilityType.weekly: 'weekly',
		RepeatabilityType.monthly: 'monthly',
	}[this]!;
}
