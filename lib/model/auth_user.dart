import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class AuthUser extends Equatable {
	final String id;

	const AuthUser({@required this.id});

	static const empty = AuthUser(id: '');

  @override
  List<Object> get props => [id];
}
