import 'dart:io';

import 'package:lastu_pdate_chat_app/feature/mainView/data/datasources/message_remote_data_source.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/data/repositories/MessageMapper.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/entities/MessageEtity.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/repositories/repo.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource _dataSource;
  final String _currentUserId;

  MessageRepositoryImpl(this._dataSource, this._currentUserId);

  @override
  Future<MessageEntity> sendMessage({
    required String receiver_id,
    String? message,
    String? imageUrl,
    required String messageId,
    required String chatId,
  }) async {
    final model = await _dataSource.sendMessage(
      senderId: _currentUserId,
      receiverId: receiver_id,
      chatId: chatId,
      messageId: messageId,
      message: message,
      imageUrl: imageUrl,
    );
    return Messagemapper().toEntity(model);
  }

  @override
  Stream<List<MessageEntity>>fetchMessages({ required String chatId,}){
    return _dataSource
        .watchMessages(chatId)
        .map((models) => models.map((m) => Messagemapper().toEntity(m)).toList());
  }

  @override
  Future<void> deleteMessage(int messageId) {
    return _dataSource.deleteMessage(messageId);
  }
    
    
  



  @override
  Future<String?> sendAudioMessage({required File audioFile, required String receiverId}) {
    return _dataSource.sendAudioMessage(audioFile: audioFile, receiverId: receiverId);
  }
  
  @override
  Future<String?> uploadImageToSupabase(File file) {
    return _dataSource.uploadImageToSupabase(file); 
  }
  
  @override
  Future<String?> uploadFileToSupabase({required String receiverId}) {
    return _dataSource.uploadFileToSupabase(receiverId: receiverId);
  }

}
