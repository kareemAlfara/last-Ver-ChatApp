import 'package:lastu_pdate_chat_app/feature/mainView/domain/repositories/repo.dart';

class uploadFileToSupabaseUsecase {
  final MessageRepository messageRepository;
  uploadFileToSupabaseUsecase({required this.messageRepository});

  Future<String?> Execute(String receiverId) async {
    return await messageRepository.uploadFileToSupabase(receiverId: receiverId);
  }


}