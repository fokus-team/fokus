/// An extension to the bloc state management library
/// which simplifies common state transitions
///
/// Concepts:
/// * State
/// * Data
/// * Status
library stateful_bloc;

export 'src/stateful_base.dart' show Action;
export 'src/stateful_bloc.dart';
export 'src/stateful_cubit.dart';
export 'src/stateful_state.dart' hide ActionType;
