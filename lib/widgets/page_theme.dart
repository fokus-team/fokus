import 'package:flutter/material.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/utils/ui/theme_config.dart';

class PageTheme extends StatelessWidget {
	final Widget child;
	final AppSectionStyle style;

	static final AppSectionStyle loginSectionStyle = AppSectionStyle(
		pageBackgroundColor: AppColors.mainBackgroundColor,
	);

	static final AppSectionStyle caregiverSectionStyle = AppSectionStyle(
		buttonColor: AppColors.caregiverButtonColor,
		appHeaderColor: AppColors.caregiverBackgroundColor
	);

	static final AppSectionStyle childSectionStyle = AppSectionStyle(
		buttonColor: AppColors.childButtonColor,
		appHeaderColor: AppColors.childBackgroundColor
	);

	static final Map<AppPageSection, AppSectionStyle> _styles = {
		AppPageSection.login: PageTheme.loginSectionStyle,
		AppPageSection.caregiver: PageTheme.caregiverSectionStyle,
		AppPageSection.child: PageTheme.childSectionStyle,
	};

	PageTheme._({required this.style, required this.child});
	PageTheme.loginSection({required Widget child}) : this._(style: loginSectionStyle, child: child);
	PageTheme.caregiverSection({required Widget child}) : this._(style: caregiverSectionStyle, child: child);
	PageTheme.childSection({required Widget child}) : this._(style: childSectionStyle, child: child);

	factory PageTheme.parametrizedSection({required AuthenticationState authState, AppPageSection? section, required Widget child}) {
		if (section == null) {
			if (authState.status == AuthenticationStatus.authenticated)
				section = authState.user!.role == UserRole.caregiver ? AppPageSection.caregiver : AppPageSection.child;
			else
				section = AppPageSection.login;
		}
		return PageTheme._(style: _styles[section]!, child: child);
	}

	@override
	Widget build(BuildContext context) {
		return Theme(
			data: Theme.of(context).copyWith(
				scaffoldBackgroundColor: style.pageBackgroundColor,
				buttonColor: style.buttonColor,
				buttonTheme: Theme.of(context).buttonTheme.copyWith(
					buttonColor: style.buttonColor
				),
				appBarTheme: Theme.of(context).appBarTheme.copyWith(
					color: style.appHeaderColor
				)
			),
			child: child,
		);
	}
}
