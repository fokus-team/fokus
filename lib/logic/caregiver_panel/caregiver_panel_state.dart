part of 'caregiver_panel_cubit.dart';

abstract class CaregiverPanelState extends Equatable {
  const CaregiverPanelState();
  
  @override
  List<Object> get props => [];
}

class CaregiverPanelInitial extends CaregiverPanelState {}

class CaregiverPanelLoadInProgress extends CaregiverPanelState {}

class CaregiverPanelLoadSuccess extends CaregiverPanelState {
	final List<UIChild> children;
	final Map<ObjectId, String> friends;

	CaregiverPanelLoadSuccess(this.children, this.friends);

	@override
	List<Object> get props => [children, friends];

	@override
  String toString() {
    return 'CaregiverPanelLoadSuccess{children: $children, friends: $friends}';
  }
}
