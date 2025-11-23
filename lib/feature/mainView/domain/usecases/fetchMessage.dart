import 'package:lastu_pdate_chat_app/feature/mainView/domain/entities/MessageEtity.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/repositories/repo.dart';

class FetchmessageUsecase {
  final MessageRepository repository;
  FetchmessageUsecase(this.repository);
  Stream<List<MessageEntity>> Execute({required String chatId}) {
    return repository.fetchMessages(chatId: chatId);
  }
}
