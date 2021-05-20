import 'package:flutter/material.dart';
import 'package:fokus/utils/ui/theme_config.dart';

class SlidingCard extends StatefulWidget {
	final List<Widget> content;
	final Color cardColor;
	final showFirst;

  SlidingCard({required Key key, required this.content, required this.cardColor, this.showFirst = false}) : super(key: key);
  @override
  SlidingCardState createState() => SlidingCardState();
}

class SlidingCardState extends State<SlidingCard> with SingleTickerProviderStateMixin {
	late Animation<Offset> _offsetAnimation;
	late AnimationController _slideController;
	late ScrollController _scrollController;

	@override
  Widget build(BuildContext context) {
    return SlideTransition(
    	position: _offsetAnimation,
    	child: NotificationListener<OverscrollIndicatorNotification>(
    		onNotification: (overscroll) {
    			overscroll.disallowGlow();
    			return false;
    		},
    		child: Padding(
    			padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 0, top: 0),
    			child: ListView(
    				shrinkWrap: false,
    				controller: _scrollController,
    				physics: ClampingScrollPhysics(),
    				padding: EdgeInsets.all(0),
    				children: [
    					Container(
    						decoration: AppBoxProperties.elevatedContainer.copyWith(color: this.widget.cardColor, borderRadius: BorderRadius.vertical(bottom: Radius.circular(4))),
    						child: Padding(
    							padding: const EdgeInsets.all(12.0),
    							child: Column(
    								children: this.widget.content
    							),
    						),
    					),
    					SizedBox(
    						height: 100,
    					)
    				]
    			),
    		),
    	),
    );
  }

  @override
	void initState() {
    super.initState();
		_slideController = AnimationController(
			duration: const Duration(seconds: 2),
			vsync: this,
		);
		_offsetAnimation = Tween<Offset>(
			begin: Offset(0, -2),
			end: Offset.zero,
		).animate(CurvedAnimation(
			parent: _slideController,
			curve: Curves.easeInOutQuint,
		));
		_scrollController = ScrollController();
		WidgetsBinding.instance!.addPostFrameCallback((_) {
			jumpToEnd();
			if(this.widget.showFirst) openCard();
		});
	}

  void closeCard() {
		_scrollController.animateTo(
			_scrollController.position.maxScrollExtent,
			duration: Duration(milliseconds: 1000),
			curve: Curves.easeInOutQuint
		);
		_slideController.reverse();
	}

	void openCard() {
		_scrollController.animateTo(
			_scrollController.position.minScrollExtent,
			duration: Duration(milliseconds: 3000),
			curve: Curves.easeInOutQuint
		);
		_slideController.forward();
	}

	void jumpToEnd() {
		_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
	}

	@override
  void dispose() {
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
