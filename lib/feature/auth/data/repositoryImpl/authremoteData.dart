import 'package:lastu_pdate_chat_app/feature/auth/data/models/usersmodel.dart';
import 'package:lastu_pdate_chat_app/feature/auth/data/repositoryImpl/auth_local_data_source.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authremotedata {
  Future<Usersmodel>createuser({
      required String email,
    required String name,
    required String image,
    required String password,
    required String phonenumber,
  })async{
    
      final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  final Usersmodel usersmodel = Usersmodel(
      image: image,
      name: name,
      user_id: response.user!.id,
      email: email,
    );
    if (response != null) {
      await Supabase.instance.client.from("users").insert({
        'user_uid': response.user!.id, // Supabase auth ID
        'email': email,
        'name': name,
        'image': image,
        "password": password,
        "phonenumber": phonenumber,
      });

      if (response.user != null) {
        uid = response.user!.id;

      AuthLocalDataSource().saveUser(uid!);
      }
    }
  

    return usersmodel;
  }
  
}