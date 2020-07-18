part of 'children_list_cubit.dart';

abstract class ChildrenListState extends Equatable {
  const ChildrenListState();
  
  @override
  List<Object> get props => [];
}

class ChildrenListInitial extends ChildrenListState {}

class ChildrenListLoadInProgress extends ChildrenListState {}

class ChildrenListLoadSuccess extends ChildrenListState {
	final List<UIChild> children;

	ChildrenListLoadSuccess(this.children);
}
