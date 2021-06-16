import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../model/db/gamification/currency.dart';
import '../../model/db/user/caregiver.dart';
import '../../services/data/data_repository.dart';
import '../common/auth_bloc/authentication_bloc.dart';
import '../common/stateful/stateful_cubit.dart';

class CaregiverCurrenciesCubit extends StatefulCubit {
	final AuthenticationBloc _authBloc;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverCurrenciesCubit(ModalRoute pageRoute, this._authBloc) : super(pageRoute);

	@override
  Future doLoadData() async {
		emit(CaregiverCurrenciesState(currencies: (activeUser! as Caregiver).currencies ?? []));
  }

	void updateCurrencies(List<Currency> currencyList) async {
		if (!beginSubmit(CaregiverCurrenciesState(currencies: currencyList)))
			return;
		var user = activeUser! as Caregiver;
		_authBloc.add(AuthenticationActiveUserUpdated(Caregiver.copyFrom(user, currencies: currencyList)));
		var currencies = currencyList.map((currency) => Currency(type: currency.type, name: currency.name)).toList();
		await _dataRepository.updateCurrencies(user.id!, currencies);
		emit(CaregiverCurrenciesState(currencies: currencyList, submissionState: DataSubmissionState.submissionSuccess));
	}
}

class CaregiverCurrenciesState extends StatefulState {
	final List<Currency> currencies;

	CaregiverCurrenciesState({required this.currencies, DataSubmissionState? submissionState}) : super.loaded(submissionState);

	@override
  StatefulState withSubmitState(DataSubmissionState submissionState) => CaregiverCurrenciesState(currencies: currencies, submissionState: submissionState);

  @override
	List<Object?> get props => super.props..add(currencies);
}
