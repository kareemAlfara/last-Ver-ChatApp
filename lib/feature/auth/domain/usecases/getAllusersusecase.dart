import 'package:lastu_pdate_chat_app/feature/auth/domain/entities/userEntity.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/repository/repo.dart';

class Getallusersusecase {
  final AuthRepo authRepository;
  Getallusersusecase({required this.authRepository});
 Future<List<Userentity>> execute(){
return authRepository.getAllusers();
}

}