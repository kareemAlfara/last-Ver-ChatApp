import 'dart:io';

import 'package:lastu_pdate_chat_app/feature/mainView/domain/repositories/repo.dart';

class uploadImageToSupabaseUsecase {
  final MessageRepository messageRepository;
  uploadImageToSupabaseUsecase({required this.messageRepository});
  Future<String?> Execute(File file) async {
    return await messageRepository.uploadImageToSupabase(file);
  }
}