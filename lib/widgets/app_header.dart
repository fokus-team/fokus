import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fokus/logic/auth/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/general/app_avatar.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/buttons/back_icon_button.dart';

enum AppHeaderType { greetings, normal, widget }

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
	final Widget appHeaderWidget;
	final String helpPage;
	final Widget popupMenuWidget;
	final TabBar tabs;
	final bool isConstrained;

	AppHeader({this.title, this.text, this.headerActionButtons, this.headerType, this.appHeaderWidget, this.helpPage, this.popupMenuWidget, this.tabs, this.isConstrained = false});
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
	AppHeader.widget({String title, String text, List<HeaderActionButton> headerActionButtons, Widget appHeaderWidget, String helpPage, Widget popupMenuWidget, TabBar tabs, bool isConstrained = false}) : this(
		title: title,
		text: text,
		headerActionButtons: headerActionButtons,
		headerType: AppHeaderType.widget,
		appHeaderWidget: appHeaderWidget,
		helpPage: helpPage,
		popupMenuWidget: popupMenuWidget,
		tabs: tabs,
		isConstrained: isConstrained
	);

	@override
	Widget build(BuildContext context) {
		if(headerType == AppHeaderType.greetings)
			return buildGreetings(context);
		else if(headerType == AppHeaderType.widget)
			return buildWidget(context);
		else
			return buildNormal(context);
	}

	Widget headerImage(UIUser user) {
		if(user.role == UserRole.caregiver) {
			return Image.asset('assets/image/sunflower_logo.png', height: 64);
		} else {
			return AppAvatar(user.avatar, color: childAvatars[user.avatar].color);
		}
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
		if(button.customContent != null) {
			return GestureDetector(
				onTap: button.action,
				child: Container(
					margin: EdgeInsets.all(4.0),
					decoration: ShapeDecoration(
						shape: Theme.of(context).buttonTheme.shape,
						color: button.backgroundColor ?? Colors.transparent
					),
					padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
					child: button.customContent
				)
			);
		}
		return Container(
			padding: EdgeInsets.all(4.0),
			child: FlatButton(
				onPressed: button.action,
				color: (button.backgroundColor != null) ? button.backgroundColor : Theme.of(context).buttonColor,
				padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
				child: Row(
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
				style: Theme.of(context).textTheme.bodyText1,
			)
		);
	}

	Widget buildHeaderContainer(BuildContext context, Widget innerContent, {double horizontalEdge = 8.0, double verticalEdge = 10.0}) {
		return Material(
			elevation: 4.0,
			color: Theme.of(context).appBarTheme.color,
			child: Container(
				padding: EdgeInsets.symmetric(vertical: verticalEdge, horizontal: horizontalEdge),
				child: SafeArea(
					child: Column(
						children: <Widget>[
							innerContent,
							if (text != null)
								headerTextField(context, text),
							if (headerActionButtons != null)
							Container(
								height: 48,
								alignment: Alignment.centerLeft,
								child: ListView(
									physics: BouncingScrollPhysics(),
									shrinkWrap: true,
									scrollDirection: Axis.horizontal,
									children: headerActionButtons.map((element) => headerActionButton(context, element)).toList()
								)
							)
						]
					)
				)
			)
		);
	}

	Widget buildGreetings(BuildContext context) {
		// ignore: close_sinks
		var authenticationBloc = context.bloc<AuthenticationBloc>();
		var currentUser = authenticationBloc.state.user;

		return buildHeaderContainer(context,
			Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: <Widget>[
					Row(
						children: <Widget>[
							Padding(
								padding: EdgeInsets.only(left: 4.0, right: 8.0),
								child: currentUser != null ? headerImage(currentUser) : Container()
							),
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: <Widget>[
									RichText(
										text: TextSpan(
											text: '${AppLocales.of(context).translate('page.${currentUser?.role?.name}Section.panel.header.greetings')},\n',
											style: TextStyle(color: Colors.white, fontSize: 20),
											children: <TextSpan>[
												TextSpan(
													text: currentUser?.name ?? '',
													style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white, height: 1.1)
												)
											]
										),
									)
								],
							),
						]
					),
					_userHeaderIcons(context),
				]
			)
		);
	}

	Widget buildNormal(BuildContext context) {
		return buildHeaderContainer(context,
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
					_userHeaderIcons(context),
				]
			)
		);
	}

	Widget buildWidget(BuildContext context) {
		return buildHeaderContainer(context,
			Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					Row(
						mainAxisSize: MainAxisSize.min,
						mainAxisAlignment: MainAxisAlignment.start,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Expanded(
								child: ListTile(
									dense: true,
									contentPadding: EdgeInsets.symmetric(horizontal: 4.0).copyWith(top: tabs != null ? 6.0 : 0.0),
									trailing: Row(
										mainAxisSize: MainAxisSize.min,
										mainAxisAlignment: MainAxisAlignment.end,
										crossAxisAlignment: CrossAxisAlignment.center,
										children: <Widget>[
											this.helpPage != null ? HelpIconButton(helpPage: helpPage) : SizedBox.shrink(),
											this.popupMenuWidget != null ? popupMenuWidget : SizedBox.shrink()
										],
									),
									leading: BackIconButton(),
									title: Padding(
										padding: EdgeInsets.only(left: 4.0),
										child: Text(
											AppLocales.of(context).translate(title), 
											style: Theme.of(context).textTheme.headline3.copyWith(color: Colors.white, fontSize: 20.0),
											overflow: TextOverflow.ellipsis,
											maxLines: isConstrained ? 1 : 2
										)
									)
								)
							)
						]
					),
					appHeaderWidget,
					if(tabs != null)
						tabs
				]
			),
			verticalEdge: tabs != null ? 0.0 : 6.0,
			horizontalEdge: 0.0
		);
	 }

	 Widget _userHeaderIcons(BuildContext context) {
		return Row(
			children: <Widget>[
				// Supporting system notification only for now
				// headerIconButton(Icons.notifications, () => Navigator.of(context).pushNamed(AppPage.notificationsPage.name)),
				PopupMenuList(
					lightTheme: true,
					items: [
						UIButton('actions.signOut', () => context.bloc<AuthenticationBloc>().add(AuthenticationSignOutRequested())),
						UIButton('navigation.settings', () => Navigator.of(context).pushNamed(AppPage.settingsPage.name)),
					]
				),
			],
		);
	 }
}

class ChildCustomHeader extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		UIChild currentUser = context.bloc<AuthenticationBloc>().state.user;
		var points = currentUser?.points ?? {};

		return AppHeader.greetings(text: 'page.childSection.panel.header.pageHint', headerActionButtons: [
			HeaderActionButton.custom(
				Container(
					child: Row(
						children: <Widget>[
							Text(
								'${AppLocales.of(context).translate('page.childSection.panel.header.myPoints')}: ',
								style: Theme.of(context).textTheme.button.copyWith(color: AppColors.darkTextColor)
							),
							for (var currency in points.entries)
								Padding(
									padding: EdgeInsets.only(left: 4.0),
									child: AttributeChip.withCurrency(content: '${currency.value}', currencyType: currency.key)
								),
							if(points.entries.isEmpty)
								Text(AppLocales.of(context).translate('page.childSection.panel.header.noPoints'))
						]
					)
				),
				() => { log('Child detailed wallet popup') },
				Colors.white
			),
			//HeaderActionButton.normal(Icons.local_florist, 'page.childSection.panel.header.garden', () => { log("Ogród") })
		]);
	}
}
