import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/gamification/points.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UIPoints extends UICurrency {
	final ObjectId createdBy;
	final int quantity;

  UIPoints({CurrencyType type, String title, this.createdBy, this.quantity}) : super(type: type, title: title);
	UIPoints.fromUICurrency(UICurrency currency) : this(type: currency.type, title: currency.title);
	UIPoints.fromDBModel(Points points) :
			createdBy = points.createdBy,
			quantity = points.quantity,
			super(type: points.icon, title: points.name);

	UIPoints copyWith({CurrencyType type, String title, ObjectId createdBy, int quantity}) {
		return UIPoints(
			type: type ?? this.type,
			title: title ?? this.title,
			createdBy: createdBy ?? this.createdBy,
			quantity: quantity ?? this.quantity
		);
	}

	@override
	List<Object> get props => super.props..addAll([quantity, createdBy]);
}
