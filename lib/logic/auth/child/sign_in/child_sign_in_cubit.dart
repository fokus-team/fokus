import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'child_sign_in_state.dart';

class ChildSignInCubit extends Cubit<ChildSignInState> {
  ChildSignInCubit() : super(ChildSignInInitial());

  Future<void> signInWithCachedId(ObjectId childId) async {

  }

  Future<void> signInNewChild() async {

  }
}
