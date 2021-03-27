// @dart = 2.10
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/stateful/stateful_cubit.dart';
import 'package:fokus/widgets/general/app_loader.dart';

class SubmitPopConfig {
	final int count;
	final DataSubmissionState moment;

	SubmitPopConfig({this.count = 1, this.moment = DataSubmissionState.submissionInProgress});
	SubmitPopConfig.onSubmitted({this.count = 1}) : moment = DataSubmissionState.submissionSuccess;
}

class StatefulBlocBuilder<CubitType extends StatefulCubit<InitialState>, InitialState extends StatefulState, LoadedState extends InitialState> extends StatelessWidget {
  final BlocWidgetBuilder<LoadedState> builder;
	final BlocWidgetListener<InitialState> listener;
	final BlocWidgetBuilder<InitialState> loadingBuilder;

	final bool expandLoader;
	final bool overlayLoader;
	final SubmitPopConfig popConfig;

  StatefulBlocBuilder({this.builder, this.listener, this.loadingBuilder, this.expandLoader = false, this.overlayLoader = false, this.popConfig});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CubitType, InitialState>(
	    builder: (context, state) {
		    var cubit = context.watch<CubitType>();
		    if (!cubit.hasOption(StatefulOption.noAutoLoading) && state.loadingState == DataLoadingState.notLoaded)
			    cubit.loadData();
		    else if (state.loaded)
			    return builder(context, state);

		    return _getBuilderWidget(context, state);
	    },
	    listener: (context, state) {
	    	var cubit = context.read<CubitType>();
	    	if (popConfig != null && popConfig.moment == state.submissionState) {
			    for (var i = 0; i < popConfig.count; i++)
				    Navigator.of(context).pop();
		    }
		    if (listener != null)
		      listener(context, state);
				if (cubit.hasOption(StatefulOption.resetSubmissionState) && state.submitted)
					cubit.resetSubmissionState();
	    }
    );
  }

  Widget _getBuilderWidget(BuildContext context, InitialState state) {
  	var baseLoader = Center(child: AppLoader(hasOverlay: overlayLoader));
	  var defaultLoader = expandLoader ? Expanded(child: baseLoader) : baseLoader;

	  if (loadingBuilder != null) {
		  if (overlayLoader)
			  return Stack(children: [
				  loadingBuilder(context, state),
				  defaultLoader
			  ]);
		  else
			  return loadingBuilder(context, state);
	  } else
		  return expandLoader ? Expanded(child: Center(child: AppLoader())) : Center(child: AppLoader());
  }
}

class SimpleStatefulBlocBuilder<CubitType extends StatefulCubit, LoadedState extends StatefulState> extends StatefulBlocBuilder<CubitType, StatefulState, LoadedState> {
	SimpleStatefulBlocBuilder({BlocWidgetBuilder<LoadedState> builder, BlocWidgetListener<StatefulState> listener,
		BlocWidgetBuilder<StatefulState> loadingBuilder, bool expandLoader = false, SubmitPopConfig popConfig}) :
				super(builder: builder, listener: listener, loadingBuilder: loadingBuilder, expandLoader: expandLoader, popConfig: popConfig);
}
