import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastu_pdate_chat_app/src/data/models/usersmodel.dart';
import 'package:lastu_pdate_chat_app/src/services/components.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());
  static RegisterCubit get(context) => BlocProvider.of(context);
  var formkey = GlobalKey<FormState>();
  var emailcontroller = TextEditingController();
  var phonecontroller = TextEditingController();
  var passcontroller = TextEditingController();
  var namecontroller = TextEditingController();
  var imagecontroller = TextEditingController();
  bool isscure = true;
  void PassowrdMethod() {
    isscure = !isscure;
    emit(PassowrdMethodState());
  }

  createUser({
    required String email,
    required String password,
    required String name,
    required String image,
    required String phonenumber,
  }) async {
    try {
      emit(createUserLoadingState());
      if (imageUrl == null) {
        Fluttertoast.showToast(
          msg: "Please select a profile picture",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response != null) {
        await Supabase.instance.client.from("users").insert({
          'user_uid': response.user!.id, // Supabase auth ID
          'email': email,
          'name': name,
          'image': imageUrl,
          "password": password,
          "phonenumber": phonenumber,
        });
        if (response.user != null) {
          uid = response.user!.id;

          // CRITICAL FIX: Save user_id to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', uid!);

          print("User ID saved to SharedPreferences: $uid");
        }
        emit(createUsersuccessState());
      }
    } on Exception catch (e) {
      emit(createUserFailureState(error: e.toString()));
      // TODO
    }
  }

  List<Usersmodel> userslist = [];
  getAllusers() async {
    try {
      final response = await Supabase.instance.client.from('users').select();

      userslist.clear();
      for (var row in response) {
        userslist.add(Usersmodel.fromJson(row));
      }

      print("All users loaded: ${userslist.length}");
      emit(getAllUsersSuccessState());
    } on Exception catch (e) {
      emit(getAllUsersFailureState(error: e.toString()));
    }
  }

  String? imageUrl;
  Future<void> pickAndSendImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      imageUrl = await uploadImageToSupabase(file);
      if (imageUrl != null) {
        log(imageUrl.toString());
          Fluttertoast.showToast(
          msg: " a profile picture Added",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
      emit(PickImageSuccessState());
    }
  }

  Future<String?> uploadImageToSupabase(File file) async {
    final supabase = Supabase.instance.client;
    final fileExtension = path.extension(file.path); // .jpg أو .png
    final uniqueId = const Uuid().v4(); // مولد UUID فريد
    final fileName = '$uniqueId$fileExtension'; // اسم جديد وفريد
    final fileBytes = await file.readAsBytes();

    try {
      await supabase.storage
          .from('users_images')
          .uploadBinary('uploads/$fileName', fileBytes);

      // final String publicUrl = supabase.storage
      //     .from('users-images')
      //     .getPublicUrl('uploads/$fileName');

      final String publicUrl =
          'https://hmyngrmjiqpwqcwegjbi.supabase.co/storage/v1/object/public/users_images/uploads/$fileName';

      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      emit(PickImageFailureState(error: e.toString()));
      return null;
    }
  }
  @override
  Future<void> close() {
    // Clean up controllers
    emailcontroller.dispose();
    phonecontroller.dispose();
    passcontroller.dispose();
    namecontroller.dispose();
    imagecontroller.dispose();
    return super.close();
  }
}
