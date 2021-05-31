import 'dart:typed_data';
import 'package:round_spot/round_spot.dart' as round_spot;

abstract class RemoteStorageProvider {
	static const _roundSpotDirectory = 'Round Spot';

	Future uploadFile(Uint8List data, String path);

	Future uploadRSHeatMap(Uint8List data, round_spot.OutputInfo info) =>
			uploadFile(data, '$_roundSpotDirectory/${_getFileName(info)}.png');
	Future uploadRSData(Uint8List data, round_spot.OutputInfo info) =>
			uploadFile(data, '$_roundSpotDirectory/raw/${_getFileName(info)}.json');

	String _getFileName(round_spot.OutputInfo info) {
		var pageName = info.page != null ? info.page!.substring(1).replaceAll('/', '-') : '';
		var area = info.area.isNotEmpty && !info.isPopup ? '[${info.area}]' : '';
		if (pageName.isNotEmpty)
			area += ' ';
		return '$area$pageName';
	}
}
