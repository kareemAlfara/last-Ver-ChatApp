import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/cubit/registercubit/register_cubit.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/pages/loginScreen.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/widgets/registerImage.dart';
import 'package:lastu_pdate_chat_app/src/services/components.dart';



class registerBody extends StatelessWidget {
  const registerBody({super.key, required this.bgColors, required this.cubit});

  final List<List<Color>> bgColors;
  final RegisterCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        return Container(
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
                    registerImage(cubit:cubit, ),
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
                            : Icon(Icons.visibility_off, color: Colors.white),
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
                      onFieldSubmitted: (value) async {
                        FocusScope.of(context).unfocus();
                        await cubit.createUser(
                          email: cubit.emailcontroller.text,
                          name: cubit.namecontroller.text,
                          password: cubit.passcontroller.text,
                          phonenumber: cubit.phonecontroller.text,
                          image: '',
                        );
                      },
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
                          FocusScope.of(context).unfocus();
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
        );
      },
    );
  }
}

