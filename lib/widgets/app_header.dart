import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import 'package:fokus/logic/active_user/active_user_cubit.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

enum AppHeaderType { greetings, normal }

class HeaderActionButton {
	final IconData icon;
	final String text;
	final Function action;
	final Widget customContent;
	final Color backgroundColor;

	HeaderActionButton(this.icon, this.text, this.customContent, this.action, [this.backgroundColor]);
	HeaderActionButton.normal(IconData icon, String text, Function action, [Color backgroundColor])
		: this(icon, text, null, action, backgroundColor);
	HeaderActionButton.custom(Widget customContent, Function action, [Color backgroundColor])
		: this(null, null, customContent, action, backgroundColor);
}

class AppHeader extends StatelessWidget {
	final String title;
	final String text;
	final List<HeaderActionButton> headerActionButtons;
	final AppHeaderType headerType;

	AppHeader({this.title, this.text, this.headerActionButtons, this.headerType});
	AppHeader.greetings({String text, List<HeaderActionButton> headerActionButtons}) : this(
		text: text, 
		headerActionButtons: headerActionButtons,
		headerType: AppHeaderType.greetings
	);
	AppHeader.normal({String title, String text, List<HeaderActionButton> headerActionButtons}) : this(
		title: title,
		text: text, 
		headerActionButtons: headerActionButtons,
		headerType: AppHeaderType.normal
	);

  @override
  Widget build(BuildContext context) => headerType == AppHeaderType.greetings ? buildGreetings(context) : buildNormal(context);

	Image headerImage(ActiveUserPresent user) {
		// TODO Handling the avatars (based on type and avatar parameters), returning sunflower for now
		return Image.asset('assets/image/sunflower_logo.png', height: 64);
	}

	Widget headerIconButton(IconData icon, Function action) {
		return InkWell(
			customBorder: new CircleBorder(),
			onTap: action,
			child: Padding(
				padding: EdgeInsets.all(8.0),
				child:Icon(
					icon,
					size: 26.0,
					color: Colors.white
				)
			)
		);
	}
	
	Widget headerActionButton(BuildContext context, HeaderActionButton button) {
		return Container(
			padding: EdgeInsets.all(4.0),
			child: FlatButton(
				onPressed: button.action,
				color: (button.backgroundColor != null) ? button.backgroundColor : Theme.of(context).buttonColor,
				padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
				child: (button.customContent != null) ? button.customContent : Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						Padding(
							child: Icon(button.icon, color: Colors.white, size: 20),
							padding: EdgeInsets.only(right: AppBoxProperties.buttonIconPadding)
						),
						Text(
							AppLocales.of(context).translate(button.text),
							style: Theme.of(context).textTheme.button
						)
					],
				)
			)
		);
	}

	Widget headerTextField(BuildContext context, String text) {
		return Container(
			alignment: Alignment.centerLeft,
			padding: EdgeInsets.only(left: 4.0, right: 4.0, top: 8.0, bottom: 8.0),
			child: Text(
				AppLocales.of(context).translate(text),
				textAlign: TextAlign.left,
				style: Theme.of(context).textTheme.bodyText1
			)
		);
	}

	Widget buildHederContainer(BuildContext context, Widget innerContent) {
		return Material(
			elevation: 4.0,
			color: Theme.of(context).appBarTheme.color,
			child: Container(
				padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
				child: SafeArea(
					child: Column(
						children: <Widget>[
							innerContent,
							if (text != null)
								headerTextField(context, text),
							Container(
								height: 48,
								alignment: Alignment.centerLeft,
								child: ListView(
									physics: BouncingScrollPhysics(),
									shrinkWrap: true,
									scrollDirection: Axis.horizontal,
									children: headerActionButtons.map((element) => 
										headerActionButton(context, element)).toList()
								)
							)
						]
					)
				)
			)
		);
	}

	Widget buildGreetings(BuildContext context) {
		var currentUser = CubitProvider.of<ActiveUserCubit>(context).state as ActiveUserPresent;

		return buildHederContainer(context, 
			Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					Row(
						children: <Widget>[
							Padding(
								padding: EdgeInsets.only(left: 4.0, right: 8.0),
								child: headerImage(currentUser)
							),
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									RichText(
										text: TextSpan(
											text: '${AppLocales.of(context).translate('page.${currentUser.role.name}Section.panel.header.greetings')},\n',
											style: TextStyle(color: Colors.white, fontSize: 20),
											children: <TextSpan>[
												TextSpan(
													text: currentUser.name,
													style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white)
												)
											]
										),
									)
								],
							),
						]
					),
					Row(
						children: <Widget>[
							headerIconButton(Icons.notifications, () => { log("Powiadomienia") }),
							headerIconButton(
								Icons.more_vert,
								() => CubitProvider.of<ActiveUserCubit>(context).logoutUser()
							),
						],
					)
				]
			)
		);
	}

	Widget buildNormal(BuildContext context) {
		return buildHederContainer(context, 
			Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					Padding(
						padding: EdgeInsets.only(left: 4.0, top: 5.0),
						child: Text(
							AppLocales.of(context).translate(title),
							style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white)
						)
					),
					Row(
						children: <Widget>[
							headerIconButton(Icons.notifications, () => { log("Powiadomienia") }),
							headerIconButton(Icons.more_vert, () => { log("Opcje") }),
						],
					)
				]
			)
		);
	}

}
