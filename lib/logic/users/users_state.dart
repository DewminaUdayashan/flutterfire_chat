part of 'users_cubit.dart';

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object> get props => [];
}

class UsersNotLoaded extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserModel> users;

  const UsersLoaded(this.users);
  @override
  List<Object> get props => [users];
}

class UsersLoadingFailed extends UsersState {
  final Exception exception;

  const UsersLoadingFailed(this.exception);

  @override
  List<Object> get props => [exception];
}
