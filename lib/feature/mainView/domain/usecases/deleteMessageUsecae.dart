import 'package:lastu_pdate_chat_app/feature/mainView/domain/repositories/repo.dart';

class Deletemessageusecae {
  final MessageRepository messageRepository;

  Deletemessageusecae(this.messageRepository);

  Future<void> execute(int messageId) {
    return messageRepository.deleteMessage(messageId);
  }
}