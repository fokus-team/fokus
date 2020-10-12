import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/auth_bloc/authentication_bloc.dart';
import 'package:fokus/model/currency_type.dart';
import 'package:fokus/model/db/gamification/currency.dart';
import 'package:fokus/model/ui/gamification/ui_currency.dart';
import 'package:fokus/model/ui/user/ui_caregiver.dart';
import 'package:get_it/get_it.dart';

import 'package:fokus/model/ui/user/ui_user.dart';
import 'package:fokus/services/data/data_repository.dart';

class CaregiverCurrenciesCubit extends Cubit<CaregiverCurrenciesState> {
	final ActiveUserFunction _activeUser;
	final AuthenticationBloc _authBloc;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverCurrenciesCubit(Object argument, this._activeUser, this._authBloc) : super(CaregiverCurrenciesInitial());

	void doLoadData() async {
		emit(CaregiverCurrenciesInProgress());
    var user = _activeUser();
		var currencies = await _dataRepository.getCurrencies(user.id);
		emit(CaregiverCurrenciesLoadSuccess(currencies.map((currency) => UICurrency.fromDBModel(currency)).toList()));
  }

	void updateCurrencies(List<UICurrency> currencyList) async {
		emit(CaregiverCurrenciesInProgress());
    var user = _activeUser();
		_authBloc.add(AuthenticationActiveUserUpdated(UICaregiver.from(user, currencies: [UICurrency(type: CurrencyType.diamond), ...currencyList])));
		List<Currency> currencies = currencyList.map((currency) => Currency(icon: currency.type, name: currency.title)).toList();
		await _dataRepository.updateCurrencies(user.id, currencies);
		emit(CaregiverCurrenciesSubmissionSuccess());
	}

}

class CaregiverCurrenciesState extends Equatable {
	final List<UICurrency> currencies;

	const CaregiverCurrenciesState({this.currencies});

	@override
	List<Object> get props => [currencies];
}

class CaregiverCurrenciesInitial extends CaregiverCurrenciesState {}

class CaregiverCurrenciesInProgress extends CaregiverCurrenciesState {}

class CaregiverCurrenciesSubmissionSuccess extends CaregiverCurrenciesState {}

class CaregiverCurrenciesLoadSuccess extends CaregiverCurrenciesState {
	CaregiverCurrenciesLoadSuccess(List<UICurrency> currencies) : super(currencies: currencies);
}

