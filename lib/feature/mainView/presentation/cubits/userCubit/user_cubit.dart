import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/domain/usecases/uploadImageToSupabaseUsecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/entities/userEntity.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit({required this.uploadimageusecase}) : super(UserInitial());
final uploadImageToSupabaseUsecase uploadimageusecase;
  static UserCubit get(context) => BlocProvider.of(context);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String? currentImageUrl;
  File? imageFile;

  // ✅ NEW: Load user data with initial values from passed user entity
  Future<void> loadUserData({required Userentity users}) async {
    emit(UserLoading());

    try {
      // Initialize controllers with passed user data
      nameController.text = users.name ?? '';
      emailController.text = users.email ?? '';
      phoneController.text = users.phone != null ? users.phone.toString() : '';
      currentImageUrl = users.image;

      // Try to fetch latest data from Supabase
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final response = await Supabase.instance.client
            .from('users')
            .select()
            .eq('user_uid', userId)
            .single();

        nameController.text = response['name'] ?? users.name ?? '';
        emailController.text = response['email'] ?? users.email ?? '';
        final phone = response['phonenumber'];

        phoneController.text = phone != null
            ? phone.toString()
            : (users.phone != null ? users.phone.toString() : '');
        currentImageUrl = response['image'] ?? users.image;
      }

      emit(UserLoaded());
    } catch (e) {
      print('Error loading user data: $e');
      // Even if Supabase fails, we still have the initial user data
      emit(UserError(error: e.toString()));
    }
  }

  // ✅ جلب بيانات المستخدم
  // Future<void> loadUserData() async {
  //   emit(UserLoading());

  //   try {
  //     final userId = Supabase.instance.client.auth.currentUser?.id;
  //     if (userId == null) {
  //       emit(UserError(error: 'User not logged in'));
  //       return;
  //     }

  //     final response = await Supabase.instance.client
  //         .from('users')
  //         .select()
  //         .eq('user_id', userId)
  //         .single();

  //     nameController.text = response['name'] ?? '';
  //     emailController.text = response['email'] ?? '';
  //     phoneController.text = response['phone'] ?? '';
  //     bioController.text = response['bio'] ?? '';
  //     currentImageUrl = response['image'];

  //     emit(UserLoaded());
  //   } catch (e) {
  //     print('Error loading user data: $e');
  //     emit(UserError(error: 'خطأ في تحميل البيانات'));
  //   }
  // }

  // ✅ اختيار صورة
  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        emit(ImagePicked());
      }
    } catch (e) {
      print('Error picking image: $e');
      emit(UserError(error: 'خطأ في اختيار الصورة'));
    }
  }

  // ✅ رفع الصورة
  Future<String?> uploadImage() async {
    if (imageFile == null) return currentImageUrl;

    emit(ImageUploading());

    try {
final  publicUrl=    await uploadimageusecase.Execute(imageFile!);
      // final userId = Supabase.instance.client.auth.currentUser?.id;
      // final fileName =
      //     'profile_$userId${DateTime.now().millisecondsSinceEpoch}.jpg';

      // await Supabase.instance.client.storage
      //     .from('profile_images')
      //     .upload(fileName, imageFile!);

      // final publicUrl = Supabase.instance.client.storage
      //     .from('profile_images')
      //     .getPublicUrl(fileName);

      emit(ImageUploaded());
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      emit(UserError(error: 'خطأ في رفع الصورة'));
      return null;
    }
  }

  // ✅ تحديث البيانات
  Future<void> updateProfile() async {
    emit(UserUpdating());

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        emit(UserError(error: 'User not logged in'));
        return;
      }

      // رفع الصورة إذا تم تغييرها
      String? imageUrl = await uploadImage();

      // تحديث البيانات
      await Supabase.instance.client
          .from('users')
          .update({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'phonenumber': phoneController.text.trim(),

            if (imageUrl != null) 'image': imageUrl,
          })
          .eq('user_uid', userId);

      emit(UserUpdateSuccess());
    } catch (e) {
      print('Error updating profile: $e');
      emit(UserError(error: 'خطأ في تحديث البيانات'));
    }
  }

  // ✅ إعادة تعيين الصورة
  void resetImage() {
    imageFile = null;
    emit(UserLoaded());
  }

  @override
  Future<void> close() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    return super.close();
  }
}
