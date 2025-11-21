import 'package:lastu_pdate_chat_app/feature/auth/domain/repository/repo.dart';

class Uploadimageusecase {
  final AuthRepo repository;
  Uploadimageusecase(this.repository);
  Future<String?> call(file) => repository.uploadImageToSupabase(file);
}