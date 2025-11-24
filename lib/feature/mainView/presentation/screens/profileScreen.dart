import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/entities/userEntity.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/cubits/userCubit/user_cubit.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/Dependencies_Injection.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/components.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user});
  final Userentity user;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<UserCubit>()..loadUserData(users: user),
      child: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Profile updated successfully ✔'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final cubit = UserCubit.get(context);
          final isLoading = state is UserLoading || state is UserUpdating;

          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Primarycolor,
              title: Text("profile", style: TextStyle(color: Colors.white)),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: () => cubit.updateProfile(),
                    child: Text(
                      'save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            body: isLoading && state is UserLoading
                ? Center(child: CircularProgressIndicator())
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black,
                          Color(0xFF1a1a2e),
                          Color(0xFF16213e),
                          Color(0xFF0f3460),
                        ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Form(
                        child: Column(
                          children: [
                            // ✅ صورة البروفايل
                            _buildProfileImage(context, cubit, state, user),
                            SizedBox(height: 30),

                            // ✅ حقل الاسم
                            defulitTextFormField(
                              controller: cubit.nameController,

                              // label: defulttext(data: user.name),
                            ),
                            SizedBox(height: 16),

                            // ✅ حقل الإيميل
                            defulitTextFormField(
                              controller: cubit.emailController,
                              // label: defulttext(data: user.email),
                              hintText: "email",
                            ),
                            SizedBox(height: 16),

                            // ✅ حقل الهاتف
                            defulitTextFormField(
                              controller: cubit.phoneController,

                              // label: defulttext(data: user.phone.toString()),
                            ),
                            SizedBox(height: 16),

                            SizedBox(height: 30),

                            // ✅ زر الحفظ
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => cubit.updateProfile(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Primarycolor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: state is UserUpdating
                                    ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        'save changes',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(
    BuildContext context,
    UserCubit cubit,
    UserState state,
    Userentity user,
  ) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: Colors.grey[300],
          backgroundImage: _getImageProvider(cubit, user),
          child:
              (cubit.imageFile == null &&
                  cubit.currentImageUrl == null &&
                  user.image.isEmpty)
              ? Icon(Icons.person, size: 70, color: Colors.grey[600])
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Primarycolor,
            child: IconButton(
              icon: Icon(Icons.camera_alt, size: 20, color: Colors.white),
              onPressed: () => _showImageSourceDialog(context, cubit),
            ),
          ),
        ),
        if (state is ImageUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  // ✅ Helper method to get the correct image provider
  ImageProvider? _getImageProvider(UserCubit cubit, Userentity user) {
    if (cubit.imageFile != null) {
      return FileImage(cubit.imageFile!);
    } else if (cubit.currentImageUrl != null &&
        cubit.currentImageUrl!.isNotEmpty) {
      return NetworkImage(cubit.currentImageUrl!);
    } else if (user.image.isNotEmpty) {
      return NetworkImage(user.image);
    }
    return null;
  }

  void _showImageSourceDialog(BuildContext context, UserCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'choose image source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.camera_alt,
                  label: 'camera',
                  onTap: () {
                    Navigator.pop(context);
                    cubit.pickImage(ImageSource.camera);
                  },
                ),
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.photo_library,
                  label: 'gallery',
                  onTap: () {
                    Navigator.pop(context);
                    cubit.pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Primarycolor,
            child: Icon(icon, size: 35, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }
}
