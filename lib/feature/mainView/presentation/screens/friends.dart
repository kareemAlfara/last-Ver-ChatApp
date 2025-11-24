import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/cubit/logincubit/login_cubit.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/pages/loginScreen.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/screens/profileScreen.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/presentation/widgets/friendsWidegt.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/components.dart';
import 'package:lottie/lottie.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        var usersList = LoginCubit.get(context).userslist;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                navigat(
                  context,
                  widget: ProfileScreen(
                    user: LoginCubit.get(
                      context,
                    ).userslist.firstWhere((user) => user.user_id == uid),
                  ),
                );
              },
              icon: Icon(Icons.person),
            ),
            elevation: 0,
            centerTitle: true,
            title: defulttext(data: "FRIENDS ", fSize: 22),
            actions: [
              IconButton(
                onPressed: () async {
                  await LoginCubit.get(context).logout(context);

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => Loginscreen()),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.login_outlined, size: 33),
              ),
            ],
          ),
          body: state is getAllUsersLoadingState
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset("assets/images/ChatAnimation.json"),
                    ],
                  ),
                )
              : usersList.isEmpty
              ? Center(
                  child: TweenAnimationBuilder<double>(
                    duration: Duration(seconds: 40),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child: defulttext(data: "No friends found"),
                  ),
                )
              : Container(
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
                  child: ListView.separated(
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) =>
                        Frindeswidget(model: usersList[index]),
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        height: 1,
                        width: double.infinity,
                        color: Colors.grey,
                      ),
                    ),
                    itemCount: usersList.length,
                  ),
                ),
        );
      },
    );
  }
}
