import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

import '../../model/db/user/user_role.dart';
import '../../services/data/data_repository.dart';

mixin UserCodeVerifier<State> on Cubit<State> {
	@protected
	final DataRepository dataRepository = GetIt.I<DataRepository>();

	@protected
	Future<bool> verifyUserCode(String code, UserRole role) async {
		try {
			if (!await dataRepository.userExists(id: getIdFromCode(code), role: role))
				return false;
		} on FirebaseException {
			return false;
		}
		return true;
	}
}
