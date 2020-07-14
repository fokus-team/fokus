import 'package:fokus/data/model/app_page.dart';

enum UserRole { caregiver, child }

extension UserRoleName on UserRole {
	String get name => const {
		UserRole.caregiver: 'caregiver',
		UserRole.child: 'child'
	}[this];
}

extension UserRolePanelPage on UserRole {
	AppPage get panelPage => const {
		UserRole.caregiver: AppPage.caregiverPanel,
		UserRole.child: AppPage.childPanel
	}[this];
}
