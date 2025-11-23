import 'package:lastu_pdate_chat_app/feature/mainView/domain/repositories/repo.dart';

class Sendmessageusecase {
  final MessageRepository messagesRepository;
  Sendmessageusecase(this.messagesRepository);

  Future<void> Execute({
    required String receiver_id,
    String? message,
    String? imageUrl,
    required String messageId,
    required String chatId,
  }) => messagesRepository.sendMessage(
    receiver_id: receiver_id,
    message: message,
    imageUrl: imageUrl,
    messageId: messageId,
    chatId: chatId,
  );
}
