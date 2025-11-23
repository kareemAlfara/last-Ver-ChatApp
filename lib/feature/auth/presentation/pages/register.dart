import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lastu_pdate_chat_app/feature/auth/data/repositoryImpl/authRepoImpl.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/createuserUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/getAllusersusecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/uploadimageUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/cubit/registercubit/register_cubit.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/widgets/registerBody.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/screens/friends.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/components.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(
        createuserusecase: Createuserusecase(Authrepoimpl.init()),
        getallusersusecase: Getallusersusecase(
          authRepository: Authrepoimpl.init(),
        ),
        uploadimageusecase: Uploadimageusecase(Authrepoimpl.init()),
      ),
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
            body: registerBody(bgColors: bgColors, cubit: cubit),
          );
        },
        listener: (context, state) async {
          if (state is createUsersuccessState) {
            context.read<RegisterCubit>().emailcontroller.clear();
            context.read<RegisterCubit>().passcontroller.clear();
            context.read<RegisterCubit>().namecontroller.clear();
            context.read<RegisterCubit>().phonecontroller.clear();
            context.read<RegisterCubit>().imagecontroller.clear();
            final prefs = await SharedPreferences.getInstance();
            final userId = prefs.getString('user_id');
            if (userId != null) {
              // Load users using LoginCubit before navigating
              await RegisterCubit.get(context).getAllusers();
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
