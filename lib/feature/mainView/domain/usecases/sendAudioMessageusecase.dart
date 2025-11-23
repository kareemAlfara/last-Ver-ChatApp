import 'dart:io';

import 'package:lastu_pdate_chat_app/feature/mainView/domain/repositories/repo.dart';

class Sendaudiomessageusecase {
  final MessageRepository messageRepository;
  Sendaudiomessageusecase(this.messageRepository);

  Future<String?> execute({required File audioFile, required String receiverId}) {
    return messageRepository.sendAudioMessage(audioFile: audioFile, receiverId: receiverId);
  }
}