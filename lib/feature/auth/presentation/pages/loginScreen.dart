import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/cubit/logincubit/login_cubit.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/screens/friends.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/pages/register.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Loginscreen extends StatelessWidget {
  const Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state is getAllUsersFailureState) {
          Fluttertoast.showToast(
            msg: 'Error: ${state.error}',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
          // log(state.error);
        } else if (state is getUserSuccessState) {
        context.read<LoginCubit>().emailcontroller.clear();
        context.read<LoginCubit>().passcontroller.clear();
          final prefs = await SharedPreferences.getInstance();

          final userId = prefs.getString('user_id');
          if (userId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => FriendsScreen()),
            );

            Fluttertoast.showToast(
              msg: 'Success',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          }

          // // navigat(context, widget: FriendsScreen());
        }
      },
      builder: (context, state) {
        var cubit = LoginCubit.get(context);
        final List<List<Color>> bgColors = [
          [Colors.blue.shade700, Colors.purple.shade400],
          [Colors.pink.shade500, Colors.orange.shade300],
          [Colors.green.shade500, Colors.blue.shade300],
        ];
        return Scaffold(
          backgroundColor: Colors.purple.shade400,
          appBar: AppBar(
            backgroundColor: Colors.blue.shade700,
            centerTitle: true,
            title: defulttext(data: "Chat App"),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors[0],
              ),
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Form(
                key: cubit.formkey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 33),
                        
                      defulttext(data: "Login", fSize: 26),
                      SizedBox(height: 22),
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
                        onFieldSubmitted:(value)async{
                          FocusScope.of(context).unfocus();
                              cubit.getUser(
                                Email: cubit.emailcontroller.text,
                                password: cubit.passcontroller.text,
                              );
                              cubit.getAllusers();
                        } ,
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
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 33),
                        
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            if (cubit.formkey.currentState!.validate()) {
                              cubit.getUser(
                                Email: cubit.emailcontroller.text,
                                password: cubit.passcontroller.text,
                              );
                              cubit.getAllusers();
                            }
                          },
                          child: state is getUserloadingState
                              ? Center(child: CircularProgressIndicator())
                              : defulttext(data: "  Login  ", fSize: 18),
                        ),
                      ),
                      SizedBox(height: 33),
                        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          defulttext(data: "Donot Have Any Accounts "),
                          TextButton(
                            onPressed: () {
                              navigat(context, widget: RegisterScreen());
                            },
                            child: defulttext(
                              data: "Sign up",
                              color: Colors.lightBlueAccent,
                              fSize: 17,
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
               ),
          ),
        );
      },
    );
  }
}
