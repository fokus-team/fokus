import 'package:bloc/bloc.dart';
import 'package:fokus/model/db/user/user_role.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus_auth/fokus_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

mixin UserCodeVerifier<State> on Cubit<State> {
	@protected
	final DataRepository dataRepository = GetIt.I<DataRepository>();

	@protected
	Future<bool> verifyUserCode(String code, UserRole role) async {
		try {
			if (!await dataRepository.userExists(id: getIdFromCode(code), role: role))
				return false;
		} catch (e) {
			return false;
		}
		return true;
	}
}
