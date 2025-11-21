import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastu_pdate_chat_app/core/errors/AuthError.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/createuserUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/getAllusersusecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/uploadimageUsecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final Createuserusecase createuserusecase;
  final Getallusersusecase getallusersusecase;
  final Uploadimageusecase uploadimageusecase;
  RegisterCubit({
    required this.createuserusecase,
    required this.uploadimageusecase,
    required this.getallusersusecase,
  }) : super(RegisterInitial());
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
      final response = await createuserusecase.call(
        email: email,
        name: name,
        image: imageUrl!,
        password: password,
        phonenumber: phonenumber,
      );
      emit(createUsersuccessState());
    } on AuthException catch (e) {
      String userFriendlyMessage =Autherror().mapAuthErrorToUserMessage(e);
      log('Auth Error: ${e.message}, Status: ${e.statusCode}');
      emit(createUserFailureState(error: userFriendlyMessage));
    } on Exception catch (e) {
      emit(createUserFailureState(error: e.toString()));
      // TODO
    }
  }


  getAllusers() async {
    try {
      var respone =await getallusersusecase.execute();
      
      emit(getAllUsersSuccessState());
    }on AuthException catch (e) {
      String userFriendlyMessage =Autherror().mapAuthErrorToUserMessage(e);
      log('Auth Error: ${e.message}, Status: ${e.statusCode}');
      emit(getAllUsersFailureState(error: userFriendlyMessage));
    }  on Exception catch (e) {
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
    try {
      var response = await uploadimageusecase.call(file);
      return response;
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
