import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' hide Action;
import 'package:get_it/get_it.dart';
import 'package:stateful_bloc/stateful_bloc.dart';

import '../../model/db/gamification/currency.dart';
import '../../model/db/user/caregiver.dart';
import '../../services/data/data_repository.dart';
import '../common/auth_bloc/authentication_bloc.dart';
import '../common/cubit_base.dart';

class CaregiverCurrenciesCubit extends CubitBase<CaregiverCurrenciesData> {
	final AuthenticationBloc _authBloc;
  final DataRepository _dataRepository = GetIt.I<DataRepository>();

  CaregiverCurrenciesCubit(ModalRoute pageRoute, this._authBloc) : super(pageRoute);

	@override
  Future reload(_) => load(body: () async {
		return Action.finish(CaregiverCurrenciesData(currencies: (activeUser! as Caregiver).currencies ?? []));
  });

	Future updateCurrencies(List<Currency> currencyList) => submit(
	  initialData: CaregiverCurrenciesData(currencies: currencyList),
		body: () async {
			var user = activeUser! as Caregiver;
			_authBloc.add(AuthenticationActiveUserUpdated(Caregiver.copyFrom(user, currencies: currencyList)));
			var currencies = currencyList.map((currency) => Currency(type: currency.type, name: currency.name)).toList();
			await _dataRepository.updateCurrencies(user.id!, currencies);
			return Action.finish(CaregiverCurrenciesData(currencies: currencyList));
		},
	);
}

class CaregiverCurrenciesData extends Equatable {
	final List<Currency> currencies;

	CaregiverCurrenciesData({required this.currencies});

  @override
	List<Object?> get props => currencies;
}
