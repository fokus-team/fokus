import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fokus/services/app_locales.dart';
import 'package:fokus/utils/app_paths.dart';
import 'package:fokus/utils/icon_sets.dart';
import 'package:smart_select/smart_select.dart';

enum IconPickerType { reward, badge }

class IconPickerField extends StatefulWidget {
	final String title;
	final String groupTextKey;
	final Function(int) callback;
	final int value;
	final IconPickerType type;

	IconPickerField({
		@required this.title,
		@required this.groupTextKey,
		@required this.callback,
		@required this.value,
		this.type = IconPickerType.reward
	});

	IconPickerField.reward({
		String title,
		String groupTextKey,
		Function(int) callback,
		int value
	}) : this(title: title, groupTextKey: groupTextKey, callback: callback, value: value, type: IconPickerType.reward);

	IconPickerField.badge({
		String title,
		String groupTextKey,
		Function(int) callback,
		int value
	}) : this(title: title, groupTextKey: groupTextKey, callback: callback, value: value, type: IconPickerType.badge);

	@override
  State<StatefulWidget> createState() => new _IconPickerFieldState();

}

class _IconPickerFieldState extends State<IconPickerField> {

  @override
  Widget build(BuildContext context) {
		bool isRewardType = widget.type == IconPickerType.reward;

		return Padding(
			padding: EdgeInsets.symmetric(vertical: 10.0),
			child: SmartSelect<int>.single(
				leading: SvgPicture.asset(getPicturePath(isRewardType, widget.value), height: 74.0),
				title: widget.title,
				value: widget.value,
				options: List.generate((isRewardType ? rewardIcons : badgeIcons).length, (index) {
						final String name = AppLocales.of(context).translate(
							widget.groupTextKey + '.${(isRewardType ? rewardIcons : badgeIcons)[index].label.toString().split('.').last}'
						);
						return SmartSelectOption(
							title: name,
							group: name,
							value: index
						);
					}
				),
				isTwoLine: true,
				choiceConfig: SmartSelectChoiceConfig(
					glowingOverscrollIndicatorColor: Colors.teal,
					runSpacing: 10.0,
					spacing: 10.0,
					useWrap: true,
					isGrouped: true,
					builder: (item, checked, onChange) {
						return Badge(
							badgeContent: Icon(Icons.check, color: Colors.white, size: 16.0),
							badgeColor: Colors.green,
							animationType: BadgeAnimationType.scale,
							showBadge: checked != null ? checked : false,
							child: GestureDetector(
								onTap: () => { onChange(item.value, !checked) },
								child: SvgPicture.asset(getPicturePath(isRewardType, item.value), height: 64.0)
							)
						);
					}
				),
				modalType: SmartSelectModalType.bottomSheet,
				onChange: (val) => widget.callback(val)
			)
		);
  }

  String getPicturePath(bool isAwardType, int value) => isAwardType ? AssetType.rewardsIcons.getPath(value) : AssetType.badgeIcons.getPath(value);
}
