import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/reloadable/reloadable_cubit.dart';
import 'package:fokus/widgets/general/app_loader.dart';

class LoadableBlocBuilder<CubitType extends ReloadableCubit> extends StatelessWidget {
	final BlocWidgetBuilder<DataLoadSuccess> builder;

  LoadableBlocBuilder({this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CubitType, LoadableState>(
	    builder: (context, state) {
		    if (state is DataLoadInitial)
			    context.bloc<CubitType>().loadData();
		    else if (state is DataLoadSuccess)
			    return builder(context, state);
		    else if (state is DataLoadInProgress)
		      return Expanded(child: Center(child: AppLoader()));
		    return Container();
	    }
    );
  }
}
