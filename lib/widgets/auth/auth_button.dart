import 'package:flutter/material.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/services/app_locales.dart';

class AuthButton extends StatelessWidget {
	final UIButton button;
	final bool isGoogleButton;

  const AuthButton({this.button, this.isGoogleButton = false});
  const AuthButton.google(UIButton button) : this(button: button, isGoogleButton: true);

  @override
  Widget build(BuildContext context) {
	  return Row(
			children: [
				Expanded(
					child: Padding(
						padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
						child: FlatButton(
							child: Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									if(isGoogleButton)
										Container(
											decoration: BoxDecoration(
												color: Colors.white,
												borderRadius: BorderRadius.all(Radius.circular(2.0))
											),
											padding: EdgeInsets.all(8.0),
											margin: EdgeInsets.all(1.0).copyWith(left: 2.0),
											child: Image.asset('assets/image/google_logo.png', width: 23.0)
										),
									Expanded(
										child: Center(
											child: Padding(
												padding: EdgeInsets.symmetric(vertical: 12.0),
												child: Text(AppLocales.of(context).translate(button.textKey), style: Theme.of(context).textTheme.button)
											)
										)
									)
								]
							),
							padding: EdgeInsets.zero,
							onPressed: button.action != null ? () => button.action() : null,
							disabledColor: Colors.grey,
							color: isGoogleButton ? Color.fromARGB(255, 66, 133, 244) : button.color
						)
					)
				)
			]
		);
  }
}
