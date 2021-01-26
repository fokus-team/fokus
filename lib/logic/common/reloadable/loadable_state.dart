part of 'reloadable_cubit.dart';

abstract class LoadableState extends Equatable {
	@override
	List<Object> get props => [];
}

class DataLoadInitial extends LoadableState {}
class DataLoadInProgress extends LoadableState {}
abstract class DataLoadSuccess extends LoadableState {}
class DataLoadFailure extends LoadableState {}

class DataSubmissionInProgress extends LoadableState {}
class DataSubmissionSuccess extends LoadableState {}
class DataSubmissionFailure extends LoadableState {}
