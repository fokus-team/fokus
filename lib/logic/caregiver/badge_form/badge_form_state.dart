part of 'badge_form_cubit.dart';

abstract class BadgeFormState extends Equatable {
  const BadgeFormState();

  @override
  List<Object> get props => [];
}

class BadgeFormInitial extends BadgeFormState {}

class BadgeFormSubmissionInProgress extends BadgeFormState {
	BadgeFormSubmissionInProgress(BadgeFormState current) : super();
}

class BadgeFormSubmissionSuccess extends BadgeFormState {
	BadgeFormSubmissionSuccess(BadgeFormState current) : super();
}
