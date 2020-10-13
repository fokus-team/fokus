import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:fokus/utils/ui/theme_config.dart';
import 'package:lottie/lottie.dart';

class AppLoader extends StatefulWidget {
	final bool hasOverlay;

	AppLoader({
		this.hasOverlay = false
	});

  _AppLoaderState createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
  }

	@override
  void dispose() {
		controller.dispose();
		super.dispose();
	}

  Widget build(BuildContext context) {
		return FadeTransition(
			opacity: animation,
			child: Container(
				decoration: BoxDecoration(
					color: widget.hasOverlay ? Colors.black26 : Colors.transparent,
					borderRadius: BorderRadius.all(Radius.circular(AppBoxProperties.roundedCornersRadius))
				),
				alignment: Alignment.center,
				child: SizedBox(
					width: 80.0,
					height: 80.0,
					child: Lottie.asset('assets/animation/sunflower.json', onLoaded: (composition) => controller.forward())
				)
			)
		);
	}

}
