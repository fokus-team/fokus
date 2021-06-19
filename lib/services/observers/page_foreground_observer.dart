import 'package:flutter/cupertino.dart';

abstract class PageForegroundObserver {
	@protected
	void onGoToForeground();
	@protected
	void onGoToBackground();
}
