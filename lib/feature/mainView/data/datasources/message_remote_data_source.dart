import 'dart:io';

import 'package:lastu_pdate_chat_app/feature/mainView/data/models/messageModel.dart';

abstract class MessageRemoteDataSource {
  Future<Messagemodel> sendMessage({
    required String senderId,
    required String receiverId,
    required String chatId,
    required String messageId,
    String? message,
    String? imageUrl,
  });

  Stream<List<Messagemodel>> watchMessages(String chatId);

  Future<void> deleteMessage(int messageId);
  Future<String?> uploadImageToSupabase(File file);
  Future<String?> uploadFileToSupabase({required String receiverId});

  Future<String?> sendAudioMessage({
    required File audioFile,
    required String receiverId,
  });
}
