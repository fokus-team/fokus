import 'package:fokus/services/observers/data_update_observer.dart';

abstract class DataUpdateNotifier {
	void observeDataUpdates(DataUpdateObserver observer);
	void removeDataUpdateObserver(DataUpdateObserver observer);
}
