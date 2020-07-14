import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fokus/widgets/app_header.dart';

import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class ChildWallet extends StatelessWidget {
	// TODO Upgrade dialog for different currencies and what not
	@override
	Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
				height: 200,
				width: 200,
				decoration: new BoxDecoration(
					color: Colors.white,
					shape: BoxShape.rectangle,
					borderRadius: BorderRadius.circular(4.0)
				),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					crossAxisAlignment: CrossAxisAlignment.center,
					children: [
						SvgPicture.asset('assets/image/currency/diamond.svg', width: 80, fit: BoxFit.cover),
						Text('100', style: TextStyle(fontSize: 40, color: AppColors.diamondColor, fontWeight: FontWeight.bold))
					]
				)
			)
    );
	}

}

class ChildCustomHeader extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return AppHeader.greetings(text: 'page.childSection.panel.header.pageHint', headerActionButtons: [
			HeaderActionButton.custom(
				Row(
					children: <Widget>[
						// TODO Universal way of showing points
						Text('${AppLocales.of(context).translate('page.childSection.panel.header.myPoints')}: '),
						SizedBox(width: 6.0),
						Padding(
							padding: EdgeInsets.only(right: 2.0),
							child: SvgPicture.asset('assets/image/currency/diamond.svg', width: 24, fit: BoxFit.cover)
						),
						Text('100', style: TextStyle(color: AppColors.diamondColor)),
						SizedBox(width: 4.0)
					],
				), 
				() => { 
					showDialog(
						context: context,
						builder: (BuildContext context) {
							return ChildWallet();
						}
					)
				 },
				Colors.white
			),
			HeaderActionButton.normal(Icons.local_florist, 'page.childSection.panel.header.garden', () => { log("Ogród") }) // Just for visual test
		]);
	}
	
}
