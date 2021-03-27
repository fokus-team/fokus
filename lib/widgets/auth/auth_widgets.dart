// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:fokus/widgets/general/app_loader.dart';

class AuthGroup extends StatelessWidget {
	final String title;
	final String hint;
	final Widget content;
	final EdgeInsets padding;
	final bool isLoading;
	final Widget action;

	AuthGroup({
		this.title,
		this.hint,
		this.isLoading = false,
		this.padding,
		this.action,
		@required this.content
	});

  @override
  Widget build(BuildContext context) {
		return Container(
			margin: EdgeInsets.all(AppBoxProperties.screenEdgePadding).copyWith(top: 0.0),
			padding: EdgeInsets.all(6.0),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										if(title != null)
											Padding(
												padding: EdgeInsets.symmetric(horizontal: 10.0),
												child: Text(title, style: Theme.of(context).textTheme.headline1.copyWith(color: Colors.white))
											),
										if(hint != null)
											Padding(
												padding: EdgeInsets.symmetric(horizontal: 10.0),
												child: Text(hint, style: Theme.of(context).textTheme.bodyText1)
											)
									]
								)
							),
							if(action != null)
								action
						]
					),
					Container(
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.all(Radius.circular(AppBoxProperties.roundedCornersRadius))
						),
						margin: EdgeInsets.only(top: (title != null || hint != null) ? 12.0 : 0.0),
						child: Stack(
							children: [
								Padding(
									padding: padding != null ? padding : EdgeInsets.all(8.0),
									child: AutofillGroup(child: content)
								),
								Positioned.fill(
									child: AnimatedSwitcher(
										duration: Duration(milliseconds: 500),
										switchOutCurve: Curves.fastOutSlowIn,
										child: isLoading ? AppLoader(hasOverlay: true): SizedBox.shrink()
									)
								)
							]
						)
					)
				]
			)
		);
  }

}

class AuthFloatingButton extends StatelessWidget {
	final String text;
	final IconData icon;
	final Function action;

	AuthFloatingButton({
		this.text,
		this.icon,
		this.action
	});

  @override
  Widget build(BuildContext context) {
		return FlatButton.icon(
			onPressed: action,
			icon: Icon(icon, color: Colors.white),
			label: Text(text, style: Theme.of(context).textTheme.button)
		);
  }

}


class AuthDivider extends StatelessWidget {
	final String textKey;

	AuthDivider({
		this.textKey = 'or'
	});

  @override
  Widget build(BuildContext context) {
		return Row(
			children: <Widget>[
				Expanded(
					child: Container(
						margin: const EdgeInsets.only(left: 10.0, right: 20.0),
						child: Divider(
							color: Colors.black,
							height: 36,
						)
					)
				),
				Text(AppLocales.of(context).translate(textKey ?? 'or').toUpperCase()),
				Expanded(
					child: Container(
						margin: const EdgeInsets.only(left: 20.0, right: 10.0),
						child: Divider(
							color: Colors.black,
							height: 36,
						)
					)
				)
			]
		);
	}
	
}
