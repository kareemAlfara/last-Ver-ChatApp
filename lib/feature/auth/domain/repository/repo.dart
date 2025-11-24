import 'package:lastu_pdate_chat_app/feature/auth/domain/entities/userEntity.dart';

abstract class AuthRepo {
Future<Userentity>  createUser({
    required String email,
    required String name,
    required String image,
    required String password,
    required int phonenumber,
  });
  Future<void> loginUser({required String email, required String password});
  Future<void> logoutUser();
  Future<String?> uploadImageToSupabase(file);
  Future<List<Userentity>>  getAllusers();
}
