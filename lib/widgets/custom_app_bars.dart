// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';

import 'package:fokus/model/ui/gamification/ui_points.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:fokus/model/ui/user/ui_child.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/dialog_utils.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/buttons/help_icon_button.dart';
import 'package:fokus/widgets/buttons/back_icon_button.dart';

import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';
import 'package:fokus/widgets/general/app_avatar.dart';
import 'package:fokus_auth/fokus_auth.dart';

enum CustomAppBarType { greetings, normal }

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
	CustomAppBar({Key key, this.type = CustomAppBarType.normal, this.title = '', this.subtitle = '', this.icon = Icons.local_florist})
			: preferredSize = Size.fromHeight(AppBoxProperties.customAppBarHeight), super(key: key);

	@override
	final Size preferredSize;
	final CustomAppBarType type;
	final String title;
	final String subtitle;
	final IconData icon;

	@override
	_CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>{

	@override
	Widget build(BuildContext context) {
		return AppBar(
			toolbarHeight: AppBoxProperties.customAppBarHeight,
			automaticallyImplyLeading: false,
			actions: [ _popUpMenu() ],
			flexibleSpace: _buildBarContent()
		);
	}

	Widget _headerImage(UIUser user) {
		if(user.role == UserRole.caregiver) {
			if((user as UICaregiver).authMethod == AuthMethod.google)
				return AppAvatar(0, caregiverPhotoURL: (user as UICaregiver).photoURL);
			return Image.asset('assets/image/sunflower_logo.png', height: 64);
		} else {
			return AppAvatar(user.avatar, color: childAvatars[user.avatar].color);
		}
	}

	Widget _popUpMenu() {
  	// ignore: close_sinks
		var auth = BlocProvider.of<AuthenticationBloc>(context);
		return PopupMenuList(
			lightTheme: true,
			includeDivider: true,
			items: [
				UIButton('navigation.settings', () => Navigator.of(context).pushNamed(AppPage.settingsPage.name),
					null, Icons.settings),
				if(auth.state.user?.role == UserRole.caregiver)
					UIButton('navigation.caregiver.caregiverCode', () => showUserCodeDialog(context, 'navigation.caregiver.caregiverCode', getCodeFromId(auth.state.user?.id)),
						null, Icons.phonelink_lock),
				UIButton('actions.signOut', () => auth.add(AuthenticationSignOutRequested()),
					null, Icons.exit_to_app)
			]
		);
	}

	Widget _buildBarContent() {
		return BlocBuilder<AuthenticationBloc, AuthenticationState>(
			buildWhen: (oldState, newState) => newState.status != AuthenticationStatus.unauthenticated,
			builder: (context, state) {
				return SafeArea(
					child: Padding(
						padding: EdgeInsets.all(10.0),
						child: Row(
							children: <Widget>[
								Padding(
									padding: EdgeInsets.only(left: 4.0, right: 10.0),
									child: (widget.type != CustomAppBarType.normal && state.user != null) ? _headerImage(state.user) : SizedBox(
										child: Icon(widget.icon, color: Colors.white, size: 40.0),
										height: 64,
										width: 64
									)
								),
								Expanded(
									child: RichText(
										overflow: TextOverflow.fade,
										text: (widget.type != CustomAppBarType.normal && state.user != null) ? TextSpan(
											text: '${AppLocales.of(context).translate('page.${state.user.role.name}Section.panel.header.greetings')},\n',
											style: TextStyle(color: Colors.white, fontSize: 20),
											children: <TextSpan>[
												TextSpan(
													text: state.user.name ?? '',
													style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white, height: 1.1)
												)
											]
										) : TextSpan(
											text: '${AppLocales.of(context).translate(widget.title)}\n',
											style: TextStyle(color: Colors.white, fontSize: 24),
											children: <TextSpan>[
												TextSpan(
													text: AppLocales.of(context).translate(widget.subtitle),
													style: Theme.of(context).textTheme.bodyText1.copyWith(height: 1.1)
												)
											]
										)
									)
								)
							]
						)
					)
				);
			}
		);
	}

}

class CustomContentAppBar extends StatelessWidget {
	final String title;
	final Widget content;
	final String helpPage;
	final Widget popupMenuWidget;
	final TabBar tabs;
	final bool isConstrained;
	final dynamic popArgs;

	CustomContentAppBar({this.title, this.content, this.helpPage, this.popupMenuWidget, this.tabs, this.isConstrained = false, this.popArgs});

	@override
	Widget build(BuildContext context) {
		return Material(
			elevation: 4.0,
			color: Theme.of(context).appBarTheme.color,
			child: Container(
				padding: EdgeInsets.symmetric(vertical: tabs != null ? 0.0 : 6.0, horizontal: 0.0),
				child: SafeArea(
					child: Column(
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
											leading: BackIconButton(args: popArgs),
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
							content,
							if(tabs != null)
								tabs
						]
					)
				)
			)
		);
	}

}

class CustomChildAppBar extends StatefulWidget {
	final List<UIPoints> points;

	CustomChildAppBar({this.points});

	@override
	_CustomChildAppBarState createState() => new _CustomChildAppBarState();
}

class _CustomChildAppBarState extends State<CustomChildAppBar> {
	@override
	Widget build(BuildContext context) {
		var getPoints = (AuthenticationState state) => (state.user as UIChild)?.points;
		return Column(
			verticalDirection: VerticalDirection.up,
			children: [
				BlocBuilder<AuthenticationBloc, AuthenticationState>(
					buildWhen: (oldState, newState) => getPoints(oldState) != getPoints(newState),
					builder: (context, state) {
						List<UIPoints> points = getPoints(state) ?? [];
						if(points.isNotEmpty)
							return Container(
								width: double.infinity,
								padding: EdgeInsets.all(8.0),
								decoration: BoxDecoration(
									color: Colors.white,
									boxShadow: [
										BoxShadow(
											color: Colors.grey.withOpacity(0.33),
											blurRadius: 4.0,
											spreadRadius: 2.0
										)
									]
								),
								child: Wrap(
									alignment: WrapAlignment.center,
									crossAxisAlignment: WrapCrossAlignment.center,
									spacing: 4.0,
									runSpacing: 4.0,
									children: <Widget>[
										if(points.length == 1 || (MediaQuery.of(context).size.width > 380 && points.length < 4))
											Text(
												'${AppLocales.of(context).translate('page.childSection.panel.header.myPoints')}: ',
												style: Theme.of(context).textTheme.button.copyWith(color: AppColors.darkTextColor)
											),
										for (UIPoints pointCurrency in points)
											AttributeChip.withCurrency(content: '${pointCurrency.quantity}', currencyType: pointCurrency.type, tooltip: pointCurrency.title)
									]
								)
							);
						return SizedBox.shrink();
					}
				),
				CustomAppBar(type: CustomAppBarType.greetings)
			]
		);
	}
}
