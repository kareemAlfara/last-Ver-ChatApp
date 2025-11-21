import 'package:lastu_pdate_chat_app/feature/auth/domain/entities/userEntity.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/repository/repo.dart';

class Createuserusecase {
  final AuthRepo authRepository;

  Createuserusecase(this.authRepository);

  Future<Userentity> call({
    required String email,
    required String name,
    required String image,
    required String password,
    required String phonenumber,
  }) async {
    return await authRepository.createUser(
      email: email,
      name: name,
      image: image,
      password: password,
      phonenumber: phonenumber,
    );
  }
}
