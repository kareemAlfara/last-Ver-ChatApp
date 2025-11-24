part of 'user_cubit.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserLoaded extends UserState {}

final class UserUpdating extends UserState {}

final class UserUpdateSuccess extends UserState {}

final class ImagePicked extends UserState {}

final class ImageUploading extends UserState {}

final class ImageUploaded extends UserState {}

final class UserError extends UserState {
  final String error;
  UserError({required this.error});
}