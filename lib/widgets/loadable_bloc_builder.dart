import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fokus/logic/common/reloadable/reloadable_cubit.dart';
import 'package:fokus/widgets/general/app_loader.dart';

class LoadableBlocBuilder<CubitType extends ReloadableCubit, LoadedState extends LoadableState> extends StatelessWidget {
	final BlocWidgetBuilder<LoadedState> builder;
	final BlocWidgetListener<LoadableState> listener;
	final BlocWidgetBuilder<LoadableState> loadingBuilder;

	final bool expandLoader;
	final bool customLoadingHandling;
	final int onSubmitPopCount;

  LoadableBlocBuilder({this.builder, this.listener, this.loadingBuilder, this.expandLoader = false,
	    bool popOnSubmit = false, int onSubmitPopCount, this.customLoadingHandling = false}) :
			onSubmitPopCount = onSubmitPopCount ?? ((popOnSubmit ?? false) ? 1 : 0) ?? 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CubitType, LoadableState>(
	    builder: (context, state) {
		    var cubit = context.watch<CubitType>();
		    if (!cubit.hasOption(ReloadableOption.noAutoLoading) && state.loadingState == DataLoadingState.notLoaded)
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
				if (cubit.hasOption(ReloadableOption.repeatableSubmission) && state.submitted)
					cubit.resetSubmissionState();
	    }
    );
  }
}
