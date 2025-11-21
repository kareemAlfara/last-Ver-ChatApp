import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lastu_pdate_chat_app/src/presentation/cubits/logincubit/login_cubit.dart';
import 'package:lastu_pdate_chat_app/src/presentation/cubits/registercubit/register_cubit.dart';
import 'package:lastu_pdate_chat_app/src/presentation/screens/friends.dart';
import 'package:lastu_pdate_chat_app/src/presentation/screens/loginScreen.dart';
import 'package:lastu_pdate_chat_app/src/services/components.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        builder: (context, state) {
          var cubit = RegisterCubit.get(context);
          final List<List<Color>> bgColors = [
            [Colors.blue.shade700, Colors.purple.shade400],
            [Colors.pink.shade500, Colors.orange.shade300],
            [Colors.green.shade500, Colors.blue.shade300],
          ];

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue.shade700,
              centerTitle: true,
              title: defulttext(data: "Chat App"),
            ),
            body: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: bgColors[0],
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: cubit.formkey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 11),

                        defulttext(data: "Register", fSize: 26),

                        SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                        cubit.imageUrl ??
                                            "https://i.pinimg.com/736x/c0/74/9b/c0749b7cc401421662ae901ec8f9f660.jpg",
                                      ),
                                    ),
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  width: 150,
                                  height: 160,
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await cubit.pickAndSendImage(
                                      source: ImageSource.gallery,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.photo_camera,
                                    color: Colors.blueAccent,
                                    size: 33,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        defulitTextFormField(
                          controller: cubit.emailcontroller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "please inter ther Email";
                            }
                            return null;
                          },
                          title: "Email",
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 22),
                        defulitTextFormField(
                          isobscure: cubit.isscure,
                          controller: cubit.passcontroller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "please inter ther password";
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            onPressed: () {
                              cubit.PassowrdMethod();
                            },

                            icon: cubit.isscure
                                ? Icon(Icons.visibility, color: Colors.white)
                                : Icon(
                                    Icons.visibility_off,
                                    color: Colors.white,
                                  ),
                          ),
                          title: "Password",
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 22),
                        defulitTextFormField(
                          controller: cubit.namecontroller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "please inter ther name";
                            }
                            return null;
                          },
                          title: "Name",
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 22),
                        defulitTextFormField(
                          controller: cubit.phonecontroller,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "please inter ther phonenumber";
                            }
                            return null;
                          },
                          title: "phone Number",
                          textInputAction: TextInputAction.done,
                        ),
                        SizedBox(height: 22),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () async {
                              if (cubit.formkey.currentState!.validate()) {
                                await cubit.createUser(
                                  email: cubit.emailcontroller.text,
                                  name: cubit.namecontroller.text,
                                  password: cubit.passcontroller.text,
                                  phonenumber: cubit.phonecontroller.text,
                                  image: '',
                                );
                              }
                            },
                            child: state is createUserLoadingState
                                ? Center(child: CircularProgressIndicator())
                                : defulttext(data: "  Sign up  ", fSize: 18),
                          ),
                        ),
                        SizedBox(height: 33),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            defulttext(data: "I Have an Account"),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Loginscreen(),
                                  ),
                                );
                              },
                              child: defulttext(
                                data: "login",
                                color: Colors.lightBlueAccent,
                                fSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        listener: (context, state) async {
          if (state is createUsersuccessState) {
              RegisterCubit.get(context).emailcontroller.clear();
              RegisterCubit.get(context).passcontroller.clear();
              RegisterCubit.get(context).namecontroller.clear();
              RegisterCubit.get(context).phonecontroller.clear();
              RegisterCubit.get(context).imagecontroller.clear();
          final prefs = await SharedPreferences.getInstance();
          await saveUserIdToPrefs();

         final userId = prefs.getString('user_id');
            if (userId != null) {
              // Load users using LoginCubit before navigating
              LoginCubit.get(context).getAllUser();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FriendsScreen()),
              );

              Fluttertoast.showToast(
                msg: 'Registration successful!',
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
            }
          } else if (state is createUserFailureState) {
            Fluttertoast.showToast(
              msg: 'Error: ${state.error}',
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
            log(state.error);
          }
        },
      ),
    );
  }
}
