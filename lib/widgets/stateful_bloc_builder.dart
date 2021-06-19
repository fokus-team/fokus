import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/common/stateful/stateful_cubit.dart';
import 'general/app_loader.dart';

class SubmitPopConfig {
	final int count;
	final DataSubmissionState moment;

	SubmitPopConfig({this.count = 1, this.moment = DataSubmissionState.submissionInProgress});
	SubmitPopConfig.onSubmitted({this.count = 1}) : moment = DataSubmissionState.submissionSuccess;
}

class StatefulBlocBuilder<CubitType extends StatefulCubit<CubitData>, CubitData extends Equatable> extends StatelessWidget {
  final BlocWidgetBuilder<StatefulState<CubitData>> builder;
	final BlocWidgetListener<StatefulState<CubitData>>? listener;
	final BlocWidgetBuilder<StatefulState<CubitData>>? loadingBuilder;

	final bool expandLoader;
	final bool overlayLoader;
	final SubmitPopConfig? popConfig;

  StatefulBlocBuilder({required this.builder, this.listener, this.loadingBuilder, this.expandLoader = false, this.overlayLoader = false, this.popConfig});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CubitType, StatefulState<CubitData>>(
	    builder: (context, state) {
		    if (state.loaded)
			    return builder(context, state);
		    return _getBuilderWidget(context, state);
	    },
	    listener: (context, state) {
	    	var cubit = context.read<CubitType>();
	    	if (popConfig != null && popConfig!.moment == state.submissionState) {
			    for (var i = 0; i < popConfig!.count; i++)
				    Navigator.of(context).pop();
		    }
		    if (listener != null)
		      listener!(context, state);
				if (cubit.hasOption(StatefulOption.resetSubmissionState) && state.submitted)
					cubit.resetSubmissionState();
	    }
    );
  }

  Widget _getBuilderWidget(BuildContext context, StatefulState<CubitData> state) {
	  var defaultLoader = loader(expanded: expandLoader, hasOverlay: overlayLoader);

	  if (state.notLoaded) return defaultLoader;
	  if (loadingBuilder != null) {
		  if (overlayLoader)
			  return Stack(children: [
				  loadingBuilder!(context, state),
				  defaultLoader
			  ]);
		  else
			  return loadingBuilder!(context, state);
	  } else
		  return defaultLoader;
  }

  static Widget loader({bool expanded = false, bool hasOverlay = false}) {
    var loader = Center(child: AppLoader(hasOverlay: hasOverlay));
    return expanded ? Expanded(child: loader) : loader;
  }}
