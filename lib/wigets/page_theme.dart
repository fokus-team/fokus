import 'package:flutter/material.dart';
import 'package:fokus/utils/theme_config.dart';

class PageTheme extends StatelessWidget {
	final Widget child;
	final AppSectionStyle style;

	static final AppSectionStyle loginSectionStyle = AppSectionStyle(
		pageBackgroundColor: AppColors.mainBackgroundColor,
	);

	static final AppSectionStyle caregiverSectionStyle = AppSectionStyle(
		buttonColor: AppColors.caregiverButtonColor,
		appHeaderColor: AppColors.mainBackgroundColor
	);

	static final AppSectionStyle childSectionStyle = AppSectionStyle(
		buttonColor: AppColors.childButtonColor,
		appHeaderColor: AppColors.childBackgroundColor
	);

	PageTheme({this.style, this.child});
	PageTheme.loginSection({Widget child}) : this(style: loginSectionStyle, child: child);
	PageTheme.caregiverSection({Widget child}) : this(style: caregiverSectionStyle, child: child);

	@override
	Widget build(BuildContext context) {
		return Theme(
			data: Theme.of(context).copyWith(
				scaffoldBackgroundColor: style.pageBackgroundColor,
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
