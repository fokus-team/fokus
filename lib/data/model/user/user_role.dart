enum UserRole { caregiver, child }

extension UserRoleName on UserRole {
	String get name => const {
		UserRole.caregiver: 'caregiver',
		UserRole.child: 'child'
	}[this];
}
