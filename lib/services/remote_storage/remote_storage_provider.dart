import 'dart:typed_data';

abstract class RemoteStorageProvider {
	static const _roundSpotDirectory = 'Round Spot';

	Future uploadFile(Uint8List data, String path, [Map<String, String> metadata]);

	Future uploadRSData(Uint8List data) =>
			uploadFile(data, '$_roundSpotDirectory/${DateTime.now().millisecondsSinceEpoch}.rsd');
}
