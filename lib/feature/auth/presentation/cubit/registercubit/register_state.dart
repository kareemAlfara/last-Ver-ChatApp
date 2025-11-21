part of 'register_cubit.dart';

@immutable
sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class PassowrdMethodState extends RegisterState {}

final class createUsersuccessState extends RegisterState {

}

final class createUserLoadingState extends RegisterState {}

final class createUserFailureState extends RegisterState {
  final String error;

  createUserFailureState({required this.error});
}

final class getAllUsersSuccessState extends RegisterState {}

final class getAllUsersFailureState extends RegisterState {
  final String error;

  getAllUsersFailureState({required this.error});
}
final class PickImageSuccessState extends RegisterState {}

final class PickImageFailureState extends RegisterState {
  final String error;

  PickImageFailureState({required this.error});
}
