part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class PassowrdMethodState extends LoginState {}

final class getUserSuccessState extends LoginState {}

final class getUserFailureState extends LoginState {
  final String error;

  getUserFailureState({required this.error});
}

final class getUserloadingState extends LoginState {}
final class getAllUsersSuccessState extends LoginState {}
final class getAllUsersLoadingState extends LoginState {}

final class getAllUsersFailureState extends LoginState {
  final String error;

  getAllUsersFailureState({required this.error});
}
