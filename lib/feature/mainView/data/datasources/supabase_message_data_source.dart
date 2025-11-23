import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/data/datasources/message_remote_data_source.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/data/models/messageModel.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseMessageDataSource implements MessageRemoteDataSource {
  final SupabaseClient _client;
  SupabaseMessageDataSource(this._client);

  @override
  Future<Messagemodel> sendMessage({
    required String senderId,
    required String receiverId,
    required String chatId,
    required String messageId,
    String? message,
    String? imageUrl,
  }) async {
    final response = await _client
        .from('messages')
        .insert({
          'Sender_id': senderId,
          'message_id': messageId,
          'Messages': message ?? '',
          if (imageUrl != null && imageUrl.isNotEmpty) 'files_url': imageUrl,
          'chat_between': chatId,
          'Recever_id': receiverId,
        })
        .select()
        .single();

    return Messagemodel.fromJson(response);
  }

  @override
  Stream<List<Messagemodel>> watchMessages(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_between', chatId)
        .order('created_at')
        .map((data) => data
            .map((e) => Messagemodel.fromJson(e))
            .where((msg) => !msg.deleted)
            .toList());
  }

  @override
  Future<void> deleteMessage(int messageId) async {
    await _client
        .from('messages')
        .delete() 
        .eq('id', messageId);
        

  }

  @override
  Future<String?> sendAudioMessage({
    required File audioFile,
    required String receiverId,
  }) async {
  
      final supabase = Supabase.instance.client;
      final fileExtension = path.extension(audioFile.path); // .mp3
      final uniqueId = const Uuid().v4();
      final fileName = '$uniqueId$fileExtension';
      final fileBytes = await audioFile.readAsBytes();

      // Upload audio to Supabase
      await supabase.storage
          .from('chat-files')
          .uploadBinary('uploads/$fileName', fileBytes);

      // ✅ Get public URL
      final publicUrl = supabase.storage
          .from('chat-files')
          .getPublicUrl('uploads/$fileName');

      // // ✅ Send message with audio URL
      // await sendMessage(
      //   receiver_id: receiverId,
      //   imageUrl: publicUrl,
      //   message: '', // or "Voice message"
      // );

      // // ✅ Optional: refresh messages right after sending
      //  FetchMessages(receiverId: receiverId);
return publicUrl;
  
  }
  

  @override
    Future<String?> uploadFileToSupabase({required String receiverId}) async {
    // Pick any file
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);

      final supabase = Supabase.instance.client;
      final fileExtension = path.extension(file.path); // Get .jpg, .pdf, etc
      final uniqueId = const Uuid().v4();
      final fileName = '$uniqueId$fileExtension'; // Unique name

      final fileBytes = await file.readAsBytes();

      try {
        await supabase.storage
            .from('chat-files') // 📦 Change bucket name if needed
            .uploadBinary('uploads/$fileName', fileBytes);

        // Get public URL
        final publicUrl = supabase.storage
            .from('chat-files')
            .getPublicUrl('uploads/$fileName');
        // await sendMessage(receiver_id: receiverId, imageUrl: publicUrl);
        print('Uploaded File URL: $publicUrl');
        return publicUrl;
      } catch (e) {
        print('Upload error: $e');
        return null;
      }
    } else {
      print('User canceled file picking');
      return null;
    }
  }

  @override
    Future<String?> uploadImageToSupabase(File file) async {
    final supabase = Supabase.instance.client;
    final fileExtension = path.extension(file.path); // .jpg أو .png
    final uniqueId = const Uuid().v4(); // مولد UUID فريد
    final fileName = '$uniqueId$fileExtension'; // اسم جديد وفريد
    final fileBytes = await file.readAsBytes();

    try {
      final response = await supabase.storage
          .from('chat-images')
          .uploadBinary('uploads/$fileName', fileBytes);

      // final String publicUrl = supabase.storage
      //     .from('chat-images')
      //     .getPublicUrl('uploads/$fileName');

      final String publicUrl =
          'https://orkxfcrrumuueykftemn.supabase.co/storage/v1/object/public/chat-images/uploads/$fileName';

      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  
  
}