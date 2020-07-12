import 'package:flutter/material.dart';

class AppColors {
  // Main app colors
  static final Color lightTextColor = Colors.white;
  static final Color mediumTextColor = Colors.grey[600];
  static final Color darkTextColor = Colors.black87;
  static final Color mainBackgroundColor = Color.fromARGB(255, 30, 121, 233);

  // Caregiver colors
  static final Color caregiverBackgroundColor = Color.fromARGB(255, 30, 121, 233);
  static final Color caregiverButtonColor = Colors.teal;

  // Child colors
  static final Color childBackgroundColor = Colors.lightGreen;
  static final Color childButtonColor = Colors.orange;

  // Currency colors
  static final Color diamondColor = Color.fromARGB(255, 3, 169, 244);
  static final Color emeraldColor = Color.fromARGB(255, 4, 224, 144);
  static final Color amethystColor = Color.fromARGB(255, 145, 49, 255);
  static final Color rubyColor = Color.fromARGB(255, 220, 0, 89);

}

class AppBoxProperties {
	// Paddings, margins, borders and box shadows goes here
	static final double buttonIconPadding = 4.0;
}

class AppSectionStyle {
	final Color pageBackgroundColor;
	final Color buttonColor;
	final Color appHeaderColor;

  AppSectionStyle({this.pageBackgroundColor, this.appHeaderColor, this.buttonColor});
}
