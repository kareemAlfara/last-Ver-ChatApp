import 'package:lastu_pdate_chat_app/feature/auth/data/Authmapper/Authmapper.dart';
import 'package:lastu_pdate_chat_app/feature/auth/data/models/usersmodel.dart';
import 'package:lastu_pdate_chat_app/feature/auth/data/repositoryImpl/auth_local_data_source.dart';
import 'package:lastu_pdate_chat_app/feature/auth/data/repositoryImpl/authremoteData.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/entities/userEntity.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/repository/repo.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class Authrepoimpl extends AuthRepo {
   final Authremotedata remote;
  final AuthLocalDataSource local;
  final SupabaseClient supabasee;
  Authrepoimpl(this.remote, this.local, this.supabasee);
 factory Authrepoimpl.init() {
    final client = Supabase.instance.client;

    return Authrepoimpl(
      Authremotedata(),
      AuthLocalDataSource(),
      client,
    );
  }
  @override
  Future<Userentity> createUser({
    required String email,
    required String name,
    required String image,
    required String password,
    required int phonenumber,
  }) async {
    Usersmodel usersmodel = await remote.createuser(
      email: email,
      name: name,
      image: image,
      password: password,
      phonenumber: phonenumber,
    );
    return Authmapper().toEntity(usersmodel);
  }

  @override
  Future<String?> uploadImageToSupabase(file) async {
    final supabase = supabasee;
    final fileExtension = path.extension(file.path); // .jpg أو .png
    final uniqueId = const Uuid().v4(); // مولد UUID فريد
    final fileName = '$uniqueId$fileExtension'; // اسم جديد وفريد
    final fileBytes = await file.readAsBytes();

    await supabase.storage
        .from('usres_images')
        .uploadBinary('uploads/$fileName', fileBytes);

    // final String publicUrl = supabase.storage
    //     .from('users-images')
    //     .getPublicUrl('uploads/$fileName');

    final String publicUrl =
        'https://orkxfcrrumuueykftemn.supabase.co/storage/v1/object/public/usres_images/uploads/$fileName';

    return publicUrl;
  }

  @override
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await supabasee.auth.signInWithPassword(
      password: password,
      email: email,
    );

    if (response.user != null) {
      uid = response.user!.id;

      // CRITICAL FIX: Save user_id to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', uid!);

      print("User ID saved to SharedPreferences: $uid");
    }
  }
  List<Userentity> userslist = [];



  @override
  Future<List<Userentity>> getAllusers() async {
    final response = await supabasee.from('users').select();

    userslist.clear();
    for (var row in response) {
      userslist.add(Authmapper().toEntity(Usersmodel.fromJson(row)));
    }

    print("All users loaded: ${userslist.length}");
    return userslist;
  }

  @override
  Future<void> logoutUser() async {
    await supabasee.auth.signOut();
  local.clearUser("user_id");
    // Clear local data
    userslist.clear();
  }
}
