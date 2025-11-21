import 'package:lastu_pdate_chat_app/feature/auth/data/models/usersmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthLocalDataSource {
  Future<void> saveUser(String userid, ) async {
    // final prefs = await SharedPreferences.getInstance();
  // CRITICAL FIX: Save user_id to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userid);

        print("User ID saved to SharedPreferences: $userid");
  }
   Future<void> clearUser(String userid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userid);
  
  }
}
