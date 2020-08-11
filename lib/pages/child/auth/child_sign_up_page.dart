import 'package:flutter/material.dart';

class ChildSignUpPage extends StatelessWidget {
	static const String _pageKey = 'page.loginSection.childSignUp';
	
  @override
  Widget build(BuildContext context) {
	  return Scaffold(
		  body: SafeArea(
			  child: _buildSignUpForm(context),
		  ),
	  );
  }

  Widget _buildSignUpForm(BuildContext context) {
	  return Column(
		  children: <Widget>[
		  ],
	  );
  }
}
