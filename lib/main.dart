import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lastu_pdate_chat_app/feature/auth/data/repositoryImpl/authRepoImpl.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/createuserUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/getAllusersusecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/loginusecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/logoutUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/uploadimageUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/cubit/logincubit/login_cubit.dart';
import 'package:lastu_pdate_chat_app/feature/auth/presentation/cubit/registercubit/register_cubit.dart';
import 'package:lastu_pdate_chat_app/src/presentation/screens/onboading.dart';
import 'package:lastu_pdate_chat_app/src/presentation/screens/wellcome_chatApp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://orkxfcrrumuueykftemn.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ya3hmY3JydW11dWV5a2Z0ZW1uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwODQ0MzksImV4cCI6MjA3MDY2MDQzOX0.iBOKKx2NhC0y8mEcGTW1XgB0rKsA3w-TxPuqxn_v76M",
    authOptions: const FlutterAuthClientOptions(autoRefreshToken: true),
  );

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');

  runApp(MyApp(isLoggedIn: userId != null));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isLoggedIn});
  final bool isLoggedIn;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = LoginCubit(
              loginusecase: Loginusecase(repositiry: Authrepoimpl.init()),
              logoutusecase: Logoutusecase( authRepo:  Authrepoimpl.init(), ),
              getallusersusecase: Getallusersusecase(
                authRepository: Authrepoimpl.init(),
              ),
            );
            // Always call getAllUser when app starts
            cubit.getAllusers();
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) {
            final cubit = RegisterCubit(
              createuserusecase: Createuserusecase(Authrepoimpl.init()),
              getallusersusecase: Getallusersusecase(
                authRepository: Authrepoimpl.init(),
              ),
              uploadimageusecase: Uploadimageusecase(Authrepoimpl.init()),
            );
            // Always call getAllUser when app starts
            cubit.getAllusers();
            return cubit;
          },
        ),

        // BlocProvider(create: (context) => MessagesCubit()),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: isLoggedIn ? WelcomeScreen() : OnboardingScreen(),
      ),
    );
  }
}
