import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fokus/model/ui/app_page.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:fokus/utils/theme_config.dart';
import 'package:fokus/widgets/buttons/rounded_button.dart';
import 'package:fokus/widgets/chips/timer_chip.dart';
import 'package:fokus/widgets/segment.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/ui/ui_button.dart';
import 'package:fokus/widgets/app_header.dart';
import 'package:fokus/widgets/chips/attribute_chip.dart';
import 'package:fokus/widgets/cards/item_card.dart';
import 'package:fokus/widgets/buttons/popup_menu_list.dart';

class CaregiverChildDashboardPage extends StatefulWidget {
  @override
  _CaregiverChildDashboardPageState createState() =>
      new _CaregiverChildDashboardPageState();
}

class _CaregiverChildDashboardPageState extends State<CaregiverChildDashboardPage> with TickerProviderStateMixin {
	static const String _pageKey = 'page.caregiverSection.childDashboard';
	TabController _tabController;
	int _currentIndex = 0;
	double customBottomBarHeight = 40;
	Duration bottomBarDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.animation
      ..addListener(() {
        setState(() {
          _currentIndex = (_tabController.animation.value).round();
        });
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					AppHeader.widget(
						title: '$_pageKey.header.title',
						appHeaderWidget: ItemCard(
							title: 'Maciek',
							subtitle: '2 plany na dziś',
							graphicType: GraphicAssetType.childAvatars,
							graphic: 16,
							chips: <Widget>[
								AttributeChip.withCurrency(content: '69420', currencyType: CurrencyType.amethyst)
							]
						),
						popupMenuWidget: PopupMenuList(
							lightTheme: true,
							items: [
								UIButton('$_pageKey.header.childCode', () => {}),
								UIButton.ofType(ButtonType.edit, () => {}),
								UIButton.ofType(ButtonType.unpair, () => {})
							],
						),
						tabs: TabBar(
							controller: _tabController,
							indicatorColor: Colors.white,
							indicatorWeight: 3.0,
							tabs: [
								Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.plans')),
								Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.awards')),
								Tab(text: AppLocales.of(context).translate('$_pageKey.header.tabs.achievements'))
							]
						)
					),
					Expanded(
						child: TabBarView(
							controller: _tabController,
							children: [
								_buildPlansTab(),
								_buildAwardsTab(),
								_buildAchievementsTab()
							]
						)
					)
				]
			),
			bottomNavigationBar: _buildBottomNavigation(),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
			floatingActionButton: AnimatedSwitcher(
				duration: bottomBarDuration,
				switchOutCurve: Curves.easeInOut,
				transitionBuilder: (child, animation) {
					return ScaleTransition(
						scale: animation,
						child: FadeTransition(
							opacity: animation,
							child: child
						)
					);
				},
				child: _currentIndex != 1 ? FloatingActionButton.extended(
					heroTag: null,
					materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
					backgroundColor: AppColors.formColor,
					elevation: 4.0,
					icon: Icon(_currentIndex == 0 ? Icons.description : Icons.star),
					label: Text(AppLocales.of(context).translate('$_pageKey.header.${_currentIndex == 0 ? 'assignPlanButton': 'assignBadgeButton'}')),
					onPressed: () { }
				) : SizedBox.shrink()
			)
		);
	}

	Widget _buildPlansTab() {
		return ListView(
			padding: EdgeInsets.zero,
			physics: BouncingScrollPhysics(),
			children: <Widget>[
				Container(
					margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: AppBoxProperties.screenEdgePadding).copyWith(bottom: 2.0),
					decoration: BoxDecoration(
						color: Colors.pink,
						borderRadius: BorderRadius.all(Radius.circular(AppBoxProperties.roundedCornersRadius))
					),
					child: Material(
						type: MaterialType.transparency,
						child: InkWell(
							onTap: () => {},
							splashColor: Colors.pink[600],
							borderRadius: BorderRadius.all(Radius.circular(AppBoxProperties.roundedCornersRadius)),
							child: Padding(
								padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
								child: Row(
									children: [
										Icon(Icons.warning, color: Colors.white),
										Expanded(
											child: Padding(
												padding: EdgeInsets.symmetric(horizontal: 16.0),
												child: Text(
													'Istnieją nieocenione zadania. Odwiedź stronę oceniania, aby przynać punkty za wykonane zadania.',
													style: TextStyle(color: Colors.white)
												)
											)
										),
										Icon(Icons.arrow_forward, color: Colors.red[900])
									],
								)
							)
						)
					)
				),
				Segment(
					title: '$_pageKey.content.plansTitle',
					elements: [
						ItemCard(
							title: 'Sprzątanie pokoju',
							subtitle: 'Rozpoczęty',
							isActive: true,
							progressPercentage: 0.33
						),
						ItemCard(
							title: 'Jakiś inny plan',
							subtitle: 'Oczekujący'
						),
					],
				),
				SizedBox(height: 30.0)
			]
		);
	}

	Widget _buildAwardsTab() {
		return ListView(
			padding: EdgeInsets.zero,
			physics: BouncingScrollPhysics(),
			children: <Widget>[
				Segment(
					title: '$_pageKey.content.awardsTitle',
					elements: [
						ItemCard(
							title: "Wycieczka do Zoo", 
							subtitle: "Odebrano dnia 25.08.2020 18:34",
							graphicType: GraphicAssetType.awardsIcons,
							graphic: 16,
							chips: <Widget>[
								AttributeChip.withCurrency(content: "30", currencyType: CurrencyType.diamond)
							],
						)
					]
				)
			]
		);
	}

	Widget _buildAchievementsTab() {
		return ListView(
			padding: EdgeInsets.zero,
			physics: BouncingScrollPhysics(),
			children: <Widget>[
				Segment(
					title: '$_pageKey.content.achievementsTitle',
					elements: [
						ItemCard(
							title: "Super planista", 
							subtitle: "Przyznano poziom 1 dnia 26.08.2020 20:10",
							graphicType: GraphicAssetType.badgeIcons,
							graphic: 3,
							graphicHeight: 44.0,
						)
					]
				)
			]
		);
	}

	Widget _buildBottomNavigation() {
		return AnimatedContainer(
			duration: bottomBarDuration,
			height: _currentIndex == 1 ? 0 : customBottomBarHeight,
			decoration: AppBoxProperties.elevatedContainer,
			child: SizedBox.shrink()
		);
	}

}
