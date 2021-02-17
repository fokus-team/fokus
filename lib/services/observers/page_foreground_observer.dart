import 'package:flutter/cupertino.dart';

abstract class PageForegroundObserver {
	@protected
	void onGoToForeground({bool firstTime = false});
	@protected
	void onGoToBackground();
}
