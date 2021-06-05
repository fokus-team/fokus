import 'dart:typed_data';
import 'package:round_spot/round_spot.dart' as round_spot;

abstract class RemoteStorageProvider {
	static const _roundSpotDirectory = 'Round Spot';

	Future uploadFile(Uint8List data, String path, [Map<String, String> metadata]);

	Future uploadRSHeatMap(Uint8List data, round_spot.OutputInfo info) =>
			uploadFile(data, '$_roundSpotDirectory/${_getFileName(info)}.png', info.metadata);
	Future uploadRSData(Uint8List data, round_spot.OutputInfo info) =>
			uploadFile(data, '$_roundSpotDirectory/raw/${_getFileName(info)}.json', info.metadata);

	String _getFileName(round_spot.OutputInfo info) {
		var pageName = info.page != null ? info.page!.substring(1).replaceAll('/', '-') : '';
		var area = info.area.isNotEmpty && !info.isPopup ? '[${info.area}]' : '';
		if (pageName.isNotEmpty)
			area += ' ';
		return '$area$pageName (${info.startTime})';
	}
}

extension InfoMetadata on round_spot.OutputInfo {
	Map<String, String> get metadata => {
		'page': page ?? '',
		'area': '$area',
		'startTime': '$startTime',
		'endTime': '$endTime',
		'isPopup': '$isPopup',
		//'eventCount': '$eventCount',
	};
}
