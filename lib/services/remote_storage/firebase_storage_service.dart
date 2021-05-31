import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';

import 'remote_storage_provider.dart';

class FirebaseStorageService extends RemoteStorageProvider {
	final Logger _logger = Logger('UserDbRepository');

	FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future uploadFile(Uint8List data, String path) async {
		var fileRef = _storage.ref(path);
		try {
			await fileRef.putData(data);
		} on FirebaseException catch (e, s) {
			_logger.severe('Uploading $path to remote storage failed', e, s);
		}
  }
}
