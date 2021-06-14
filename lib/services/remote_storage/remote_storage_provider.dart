import 'dart:typed_data';
import 'package:round_spot/round_spot.dart' as round_spot;

abstract class RemoteStorageProvider {
	static const _roundSpotDirectory = 'Round Spot';

	Future uploadFile(Uint8List data, String path, [Map<String, String> metadata]);

	Future uploadRSData(Uint8List data) =>
			uploadFile(data, '$_roundSpotDirectory/${DateTime.now().millisecondsSinceEpoch}.rsd');
}
