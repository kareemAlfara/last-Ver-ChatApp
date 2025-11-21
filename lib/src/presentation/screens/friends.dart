import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lastu_pdate_chat_app/src/presentation/cubits/logincubit/login_cubit.dart';
import 'package:lastu_pdate_chat_app/src/presentation/screens/loginScreen.dart';
import 'package:lastu_pdate_chat_app/src/presentation/widgets/friendsWidegt.dart';
import 'package:lastu_pdate_chat_app/src/services/components.dart';
import 'package:lottie/lottie.dart';
// Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [Lottie.asset("assets/images/ChatAnimation.json")],
//       )
        
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        var usersList = LoginCubit.get(context).userslist;
        return Scaffold(
          appBar: AppBar(
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
              ? Center(child: 
              Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Lottie.asset("assets/images/ChatAnimation.json")],
      )
              )
              :  Container(
           decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors:[
              Colors.black,
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
    ),),child:  ListView.separated(
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) =>
                        frindeswidget(model: usersList[index]),
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
