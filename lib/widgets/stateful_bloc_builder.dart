import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/widgets/general/app_loader.dart';

class StatefulBlocBuilder<CubitType extends StatefulCubit, LoadedState extends StatefulState> extends StatelessWidget {
  final BlocWidgetBuilder<LoadedState> builder;
  final BlocBuilderCondition<StatefulState> buildWhen;
	final BlocWidgetListener<StatefulState> listener;
	final BlocWidgetBuilder<StatefulState> loadingBuilder;

	final bool expandLoader;
	final bool customLoadingHandling;
	final int onSubmitPopCount;

  StatefulBlocBuilder({this.builder, this.listener, this.loadingBuilder, this.buildWhen, this.expandLoader = false,
	    bool popOnSubmit = false, int onSubmitPopCount, this.customLoadingHandling = false}) :
			onSubmitPopCount = onSubmitPopCount ?? ((popOnSubmit ?? false) ? 1 : 0) ?? 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CubitType, StatefulState>(
      buildWhen: buildWhen,
	    builder: (context, state) {
		    var cubit = context.watch<CubitType>();
		    if (!cubit.hasOption(StatefulOption.noAutoLoading) && state.loadingState == DataLoadingState.notLoaded)
			    cubit.loadData();
		    else if (state.loaded || customLoadingHandling)
			    return builder(context, state);
				if(loadingBuilder == null)
					return expandLoader ? Expanded(child: Center(child: AppLoader())) : Center(child: AppLoader());
				else return loadingBuilder(context, state);
	    },
	    listener: (context, state) {
	    	var cubit = context.read<CubitType>();
	    	if (state.submissionInProgress) {
			    for (var i = 0; i < onSubmitPopCount; i++)
				    Navigator.of(context).pop();
		    }
		    if (listener != null)
		      listener(context, state);
				if (cubit.hasOption(StatefulOption.repeatableSubmission) && state.submitted)
					cubit.resetSubmissionState();
	    }
    );
  }
}
