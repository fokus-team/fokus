import 'package:flutter/material.dart';
import 'package:fokus/utils/app_locales.dart';
import 'package:fokus/utils/theme_config.dart';

class ItemCardActionButton {
	final IconData icon;
	final Color color;
	final Function onTapped;
	final bool disabled;

	ItemCardActionButton({
		this.icon,
		this.color,
		this.onTapped,
		this.disabled = false
	});
}

class ItemCardMenuItem {
	final String text;
	final Function onTapped;

	ItemCardMenuItem({
		this.text,
		this.onTapped
	});
}

class ItemCard extends StatelessWidget {
	// Element's content
	final String title;
	final String subtitle;
	final bool image; // TEMP: show/hide image, later custom Image class?
	final double progressPercentage;
	final List<Widget> chips;
	final List<ItemCardMenuItem> menuItems;
	final ItemCardActionButton actionButton;
	final Function onTapped;
	final bool isActive;

	// Element's visual params
	BuildContext buildContext;
	final int titleMaxLines = 3;
	final double imageHeight = 80.0;
	final double progressIndicatorHeight = 10.0;
	final Color disabledButtonColor = Colors.grey[200];
  final Color inactiveProgressBar = Colors.grey[300];
  final Color activeProgressBar = Colors.lightGreen;

	ItemCard({
		@required this.title, 
		this.subtitle,
		this.image = false,
		this.progressPercentage,
		this.chips,
		this.menuItems,
		this.actionButton,
		this.onTapped,
		this.isActive = true
	});
	
	Image headerImage() {
		// TODO Handling the avatars (based on type and avatar parameters), returning sunflower for now
		return Image.asset('assets/image/sunflower_logo.png', height: imageHeight);
	}

	// Card's shape and interaction
	@override
	Widget build(BuildContext context) {
		buildContext = context;
		return IntrinsicHeight(
			child: Card(
				elevation: isActive ? 1.2 : 0.2,
				color: isActive ? Colors.white : disabledButtonColor,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)),
				margin: EdgeInsets.symmetric(
					vertical: AppBoxProperties.cardListPadding,
					horizontal: AppBoxProperties.screenEdgePadding
				),
				child: (onTapped != null) ? InkWell(
					onTap: onTapped, 
					child:  buildStructure(),
					borderRadius: BorderRadius.circular(AppBoxProperties.roundedCornersRadius)
				) : buildStructure()
			)
		);
	}

	// Layout: MainSection | ActionSection
	Widget buildbaseLayout() {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			crossAxisAlignment: CrossAxisAlignment.start,
			children: <Widget>[
				buildMainSection(),
				if((menuItems != null && menuItems.isNotEmpty) || actionButton != null)
					buildActionSection()
			]
		);
	}

	// Structure change depending on big action button (progress bar goes under ActionSection)
	Widget buildStructure() {
		if(progressPercentage != null && actionButton == null) 
			return Column(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					buildbaseLayout(),
					buildProgressBar()
				]
			);
		return buildbaseLayout();
	}

	// Inner structure of MainSection (content + sometimes progress bar)
	Widget buildMainSection() {
		return Flexible(
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				mainAxisAlignment: MainAxisAlignment.center,
				children: <Widget>[
					buildContentSection(),
					if(progressPercentage != null && actionButton != null)
						buildProgressBar()
				]
			)
		);
	}

	// Image, title, subtitle and chips
	Widget buildContentSection() {
		return Row(
			mainAxisAlignment: MainAxisAlignment.start,
			crossAxisAlignment: CrossAxisAlignment.start,
			children: <Widget>[
				if(image)
					Padding(
						padding: EdgeInsets.all(4.0),
						child: headerImage()
					),
				Expanded(
					flex: 1, 
					child: Padding(
						padding: image ? EdgeInsets.all(6.0) : EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: <Widget>[
								Text(
									title, 
									style: Theme.of(buildContext).textTheme.headline3,
									overflow: TextOverflow.ellipsis,
									maxLines: titleMaxLines
								),
								if(subtitle != null)
									Text(
										subtitle, 
										style: Theme.of(buildContext).textTheme.subtitle2,
										overflow: TextOverflow.fade,
										softWrap: false,
									),
								if(chips != null && chips.isNotEmpty)
									Padding(
										padding: EdgeInsets.only(top: 8.0),
										child: Wrap(
											spacing: 2,
											runSpacing: 4,
											children: chips
										)
									)
							],
						)
					)
				)
			]
		);
	}

	// Bottom progress bar
	Widget buildProgressBar() {
		return Container(
			height: progressIndicatorHeight,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.only(bottomLeft: Radius.circular(AppBoxProperties.roundedCornersRadius))
			),
			clipBehavior: Clip.hardEdge,
			child: LinearProgressIndicator(
				value: progressPercentage,
				backgroundColor: inactiveProgressBar,
				valueColor: AlwaysStoppedAnimation<Color>(activeProgressBar)
			)
		);
	}

	// Menu options or big action button
	Widget buildActionSection() {
		if(menuItems != null && menuItems.isNotEmpty) {
			return InkWell(
				customBorder: new CircleBorder(),
				child: PopupMenuButton<int>(
					icon: Icon(
						Icons.more_vert,
						size: 26.0
					),
					onSelected: (int value) => { menuItems[value].onTapped() },
					itemBuilder: (context) => [
						for (int i = 0; i < menuItems.length; i++)
							PopupMenuItem(value: i, child: Text(AppLocales.of(context).translate(menuItems[i].text)))
					],
				)
			);
		}
		if(actionButton != null) {
			if(actionButton.disabled) {
				return FlatButton(
					onPressed: null,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(AppBoxProperties.roundedCornersRadius))),
					child: Center(
						child: Icon(actionButton.icon, color: actionButton.color, size: 40.0),
					)
				);
			} else {
				return FlatButton(
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(AppBoxProperties.roundedCornersRadius))),
					onPressed: actionButton.disabled ? null : actionButton.onTapped,
					color: actionButton.color,
					disabledColor: disabledButtonColor,
					child: Center(
						child: Icon(actionButton.icon, color: Colors.white, size: 40.0),
					)
				);
			}
		}
		return SizedBox(width: 0, height: 0);
	}

}
