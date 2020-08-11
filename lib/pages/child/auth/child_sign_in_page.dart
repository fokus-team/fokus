import 'package:flutter/material.dart';

import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class ChildSignInPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.childSignIn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
	    body: SafeArea(
			  child: _buildSignInForm(context)
	    ),
    );
  }

	Widget _buildSignInForm(BuildContext context) {
		return Column(
			children: <Widget>[
				MaterialButton(
					child: Text(AppLocales.of(context).translate('$_pageKey.createNewProfile')),
					color: AppColors.childButtonColor,
					onPressed: () => Navigator.of(context).pushNamed(AppPage.childSignUpPage.name),
				),
			],
		);
	}
}
