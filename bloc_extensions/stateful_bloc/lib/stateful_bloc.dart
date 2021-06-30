/// An extension to the bloc state management library
/// which simplifies common state transitions.
///
/// ## Background
/// Stateful extension is built to support the
/// commonly used patterns of __data loading__ and __submission__.
/// Each one of them usually consist of the following state classes:
/// * `NameInitial`
/// * `NameActionInProgress`
/// * `NameActionSuccess`
/// * `NameActionFailure`
///
/// They are commonly used as follows:
/// * `NameInitial` is the `initialState` set in constructor
/// * when the action is triggered the `NameActionInProgress` is set
/// * some logic is executed to fetch / send / transform the data
/// * depending on the result `NameActionSuccess` / `NameActionFailure` is set
///
/// This extension abstracts away both the state types and their
/// transitions leaving only the logic to be supplied by the implementer.
///
/// ## Advantages
/// Main advantages of using the Stateful extension:
/// * __Cubit / Bloc simplification__ - you don't have to worry
/// about states, just focus on the logic and the data it changes
/// * __State simplification__ - no more repeating the same inheritance tree
/// for each component, just focus on the data that's being provided
/// * __Uniform state types across the whole codebase__ - aside from
/// the standardization itself this makes it easier to reuse state dependent
/// widgets across multiple UI components (like showing a loading indicator
/// on [ActionStatus.ongoing] or an error message on [ActionStatus.failed]).
///
/// ## Concepts
/// Main concepts used in the code and documentation:
/// * __State__ - the whole Bloc / Cubit state ([StatefulState<Data>])
/// * __Data__ - user provided state data container ([StatefulState.data])
/// * __Action__ - either loading or submission operation
/// * __Status__ - one of the possible states of an action ([ActionStatus])
///
/// ## State type abstraction
/// State types are abstracted by embedding a data containing object into
/// the [StatefulState] that also contains loading and submission state fields.
/// The actual data is embedded to separate it from states while mutating.
/// State types are kept as fields instead of an inheritance tree
/// for simplicity. It improves type safety and code readability
/// by providing getters to easily check the current type.
///
/// ## State transition abstraction
/// Transitions are abstracted by exposing action wrapper methods. Logic blocks
/// are passed to them. Final status is determined by its returning value.
/// Each underlying state type transition can also change its data.
/// Check [StatefulBloc.load] and [StatefulBloc.submit] for the details.
/// 
/// ## Example
/// ### From
/// ```dart
/// abstract class PageState extends Equatable {
///   @override
///   List<Object> get props => [];
/// }
///
/// class PageStateInitial extends PageState {}
///
/// class PageStateLoadInProgress extends PageState {}
///
/// class PageStateLoadSuccess extends PageState {
///   final String data;
///
///   const LoadSuccess(this.data);
///
///   @override
///   List<Object>? get props => [data];
/// }
///
/// class PageStateLoadFailure extends PageState {}
/// ```
/// ### To
/// (used as `StatefulState<PageData>`)
/// ```dart
/// class PageData extends Equatable {
///   final String data;
///
///   const PageData(this.data);
///
///   @override
///   List<Object>? get props => [data];
/// }
/// ```
library stateful_bloc;

export 'src/stateful_base.dart' show Action;
export 'src/stateful_bloc.dart';
export 'src/stateful_cubit.dart';
export 'src/stateful_state.dart' hide ActionType;
