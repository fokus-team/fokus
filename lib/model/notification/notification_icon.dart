import 'package:fokus/utils/ui/icon_sets.dart';
import 'package:fokus/utils/ui/app_paths.dart';

class NotificationIcon {
	final AssetType type;
	final int index;
	final String name;

	const NotificationIcon._({this.type, this.index, this.name});
	const NotificationIcon(AssetType type, int index) : this._(type: type, index: index);
	const NotificationIcon.fromName(String name) : this._(name: name);

  String get getPath => name ?? type.getPath(index, AssetPathType.drawable);
}
