// supabase_remote_data_source.dart
import 'dart:io';

import 'package:lastu_pdate_chat_app/feature/mainView/data/models/messageModel.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/entities/MessageEtity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class MessageRepository {
  Future<MessageEntity> sendMessage({
    required String receiver_id,
    String? message,
    String? imageUrl,
    required String messageId,
    required String chatId,
  });
  Stream<List<MessageEntity>> fetchMessages({required String chatId});
  Future<void> deleteMessage(int messageId);
  Future<String?> sendAudioMessage({
    required File audioFile,
    required String receiverId,
  });
  Future<String?> uploadFileToSupabase({required String receiverId});
  Future<String?> uploadImageToSupabase(File file);
}
