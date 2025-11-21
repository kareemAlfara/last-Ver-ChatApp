import 'package:lastu_pdate_chat_app/feature/auth/domain/repository/repo.dart';

class Loginusecase {
  final AuthRepo repositiry;

  Loginusecase({required this.repositiry});
  call({required String email, required String password}) {
    return repositiry.loginUser(email: email, password: password);
  }
}
