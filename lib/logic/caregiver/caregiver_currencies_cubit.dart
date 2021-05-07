import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';

class CaregiverCurrenciesCubit extends StatefulCubit {
	final ActiveUserFunction _activeUser;
	final AuthenticationBloc _authBloc;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverCurrenciesCubit(Object argument, ModalRoute pageRoute, this._activeUser, this._authBloc) : super(pageRoute);

	Future doLoadData() async {
    var user = _activeUser();
		var currencies = await _dataRepository.getCurrencies(user.id!);
		emit(CaregiverCurrenciesState(currencies: currencies?.map((currency) => UICurrency.fromDBModel(currency)).toList() ?? []));
  }

	void updateCurrencies(List<UICurrency> currencyList) async {
		if (!beginSubmit(CaregiverCurrenciesState(currencies: currencyList)))
			return;
    var user = _activeUser() as UICaregiver;
		_authBloc.add(AuthenticationActiveUserUpdated(UICaregiver.from(user, currencies: [UICurrency(type: CurrencyType.diamond), ...currencyList])));
		List<Currency> currencies = currencyList.map((currency) => Currency(icon: currency.type, name: currency.title)).toList();
		await _dataRepository.updateCurrencies(user.id!, currencies);
		emit(CaregiverCurrenciesState(currencies: currencyList, submissionState: DataSubmissionState.submissionSuccess));
	}
}

class CaregiverCurrenciesState extends StatefulState {
	final List<UICurrency> currencies;

	CaregiverCurrenciesState({required this.currencies, DataSubmissionState? submissionState}) : super.loaded(submissionState);

	@override
  StatefulState withSubmitState(DataSubmissionState submissionState) => CaregiverCurrenciesState(currencies: currencies, submissionState: submissionState);

  @override
	List<Object?> get props => super.props..add(currencies);
}
