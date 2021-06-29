import 'package:flutter/material.dart';
import '../../model/ui/ui_button.dart';
import '../../services/app_locales.dart';

class AuthButton extends StatelessWidget {
	final UIButton button;
	final bool disabled;
	final bool isGoogleButton;

  const AuthButton({required this.button, this.isGoogleButton = false, this.disabled = false});
  const AuthButton.google({required UIButton button, bool disabled = false}) :
        this(button: button, isGoogleButton: true, disabled: disabled);

  @override
  Widget build(BuildContext context) {
	  return Row(
			children: [
				Expanded(
					child: Padding(
						padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
						child: TextButton(
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
							style: TextButton.styleFrom(
								padding: EdgeInsets.zero,
								onSurface: Colors.grey,
								backgroundColor: isGoogleButton ? _googleColor : button.color
							),
							onPressed: button.action != null ? () => button.action!() : null,
						)
					)
				)
			]
		);
  }

  Color get _googleColor => disabled ? Colors.grey : Color.fromARGB(255, 66, 133, 244);
}
