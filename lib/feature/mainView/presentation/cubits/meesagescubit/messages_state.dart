part of 'messages_cubit.dart';

@immutable
sealed class MessagesState {}

final class MessagesInitial extends MessagesState {}

final class MessagesInsertsuccess extends MessagesState {}

final class MessagesInsertfailure extends MessagesState {}

final class FetchmessagesSucess extends MessagesState {}

final class FetchmessagesError extends MessagesState {
  final String error;

  FetchmessagesError({required this.error});
}

final class changeSendState extends MessagesState {}

final class Messagesuccess extends MessagesState {}

final class Messagefailure extends MessagesState {
  final String error;

  Messagefailure({required this.error});
}

final class playAudiosuccess extends MessagesState {}

final class pauseAudiosuccess extends MessagesState {}

final class DurationChangedstate extends MessagesState {


  DurationChangedstate();
}

final class PositionChangedstate extends MessagesState {
    

  PositionChangedstate();
 
}
final class PlayerComplete extends MessagesState {
  

  PlayerComplete();
 
}
final class playAudio extends MessagesState {}
// ✅ إضافة States البحث
final class SearchToggleState extends MessagesState {}

final class SearchResultState extends MessagesState {}
