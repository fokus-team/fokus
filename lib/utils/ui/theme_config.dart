import 'package:flutter/material.dart';
import '../../model/currency_type.dart';

class AppColors {
  // Main app colors
  static final Color lightTextColor = Colors.white;
  static final Color mediumTextColor = Colors.grey[600]!;
  static final Color darkTextColor = Colors.black87;
  static final Color mainBackgroundColor = Color.fromARGB(255, 30, 121, 233);
	static final Color formColor = Colors.teal;
	static final Color failColor = Colors.red[400]!;
	static final Color successColor = Colors.green[400]!;
	static final Color infoColor = Colors.blue[400]!;

  // Caregiver colors
  static final Color caregiverBackgroundColor = Color.fromARGB(255, 30, 121, 233);
  static final Color caregiverButtonColor = Colors.teal;

  // Child colors
  static const Color childBackgroundColor = Colors.lightGreen;
  static final Color childButtonColor = Colors.orange;
  static final Color childActionColor = Colors.amber;
	static final List<Color> chipRatingColors = [Colors.pink, Colors.red, Colors.deepOrange, Colors.amber, Colors.lightGreen, Colors.green];
	static final Color childTaskFiller = Colors.white;
	static final Color childBreakColor = Colors.blueGrey;
	static final Color childTaskColor = Colors.lightBlue;

	static final Color negativeColor = Colors.red;
	static final Color positiveColor = Colors.lightGreen;

  static final Color notificationAccentColor = Color(0xfffdbf00);

  // Currency colors
	static final Map<CurrencyType, Color> currencyColor = {
		CurrencyType.diamond: Color.fromARGB(255, 3, 169, 244),
		CurrencyType.emerald: Color.fromARGB(255, 14, 204, 93),
		CurrencyType.amethyst: Color.fromARGB(255, 145, 49, 255),
		CurrencyType.ruby: Color.fromARGB(255, 220, 0, 89)
	};

	static final List<Color> markerColors = [
		Colors.green,
		Colors.pink,
		Colors.deepPurple,
		Colors.teal,
		Colors.orange,
		Colors.red,
		Colors.purple,
		Colors.brown
	];

}

class AnimationsProperties {
	static final Duration insertDuration = Duration(milliseconds: 800);
	static final Duration removeDuration = Duration(milliseconds: 800);
	static final Duration dragDuration = Duration(milliseconds: 200);
}

class AppBoxProperties {
	// Paddings, margins, borders and box shadows goes here
  static final double buttonIconPadding = 4.0;
  static final double roundedCornersRadius = 5.0;
  static final double screenEdgePadding = 20.0;
  static final double cardListPadding = 5.0;
  static final double containerPadding = 10.0;
  static final double columnChildrenPadding = 5.0;
  static final double sectionPadding = 20.0;
	static final double standardBottomNavHeight = 60.0;
	static final double customAppBarHeight = 84.0;
	static final double customChildAppBarHeight = 130.0;

	static final BoxDecoration elevatedContainer = BoxDecoration(
		color: Colors.white,
		shape: BoxShape.rectangle,
		boxShadow: [
			BoxShadow(
				color: Colors.grey.withOpacity(.2),
				blurRadius: 10.0,
				spreadRadius: 4.0
			)
		],
	);
	
}

class AppSectionStyle {
	final Color? pageBackgroundColor;
	final Color? buttonColor;
	final Color? appHeaderColor;

  AppSectionStyle({this.pageBackgroundColor, this.appHeaderColor, this.buttonColor});
}
