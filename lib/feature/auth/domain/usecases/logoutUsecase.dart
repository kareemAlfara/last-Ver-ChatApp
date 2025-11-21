import 'package:lastu_pdate_chat_app/feature/auth/domain/entities/userEntity.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/repository/repo.dart';

class  Logoutusecase {
  final AuthRepo authRepo;

  Logoutusecase({required this.authRepo});

  Future<void> execute() => authRepo.logoutUser();
  
}