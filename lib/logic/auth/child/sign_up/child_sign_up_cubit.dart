import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'child_sign_up_state.dart';

class ChildSignUpCubit extends Cubit<ChildSignUpState> {
  ChildSignUpCubit() : super(ChildSignUpInitial());

  Future<void> signUpFormSubmitted() async {

  }
}
