/// Collection of Bloc library extensions implementing commonly used patterns
///
/// Currently there are two extensions available for both [Cubit] and [Bloc]:
/// * [ReloadableBloc] that solves the issue
/// of outdated content when user loads back the page
/// * [StatefulBloc] that simplifies state management by handling its status
///
/// Since one of them triggers operations and the other controls them they can
/// be used together as well as separately to provide the needed functionality.
library bloc_extensions;

export 'src/reloadable/reloadable_base.dart' show ReloadableReason;
export 'src/reloadable/reloadable_bloc.dart';
export 'src/reloadable/reloadable_cubit.dart';
export 'src/stateful/stateful_bloc.dart';
export 'src/stateful/stateful_cubit.dart';
export 'src/stateful/stateful_state.dart' hide OperationType;
