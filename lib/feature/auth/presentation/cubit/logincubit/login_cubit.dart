import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lastu_pdate_chat_app/core/errors/AuthError.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/entities/userEntity.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/getAllusersusecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/loginusecase.dart';
import 'package:lastu_pdate_chat_app/feature/auth/domain/usecases/logoutUsecase.dart';
import 'package:lastu_pdate_chat_app/feature/mainView/services/components.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required this.loginusecase,
    required this.getallusersusecase,
    required this.logoutusecase,
  }) : super(LoginInitial());
  final Loginusecase loginusecase;
  final Getallusersusecase getallusersusecase;
  final Logoutusecase logoutusecase;
  static LoginCubit get(context) => BlocProvider.of(context);

  var formkey = GlobalKey<FormState>();
  var emailcontroller = TextEditingController();
  var passcontroller = TextEditingController();
  bool isscure = true;

  // Add StreamSubscription to properly manage the stream
  StreamSubscription<List<Map<String, dynamic>>>? _usersSubscription;

  void PassowrdMethod() {
    isscure = !isscure;
    emit(PassowrdMethodState());
  }

  Future<void> getUser({
    required String Email,
    required String password,
  }) async {
    emit(getUserloadingState());
    try {
      // Local validation before sending request to Supabase
      if (!Email.contains('@')) {
        emit(
          getAllUsersFailureState(error: "Please enter a valid email address."),
        );
        return;
      }

      if (password.length < 6) {
        emit(
          getAllUsersFailureState(
            error: "Password must be at least 6 characters long.",
          ),
        );
        return;
      }
      await loginusecase.call(email: Email, password: password);
      emit(getUserSuccessState());
    } on AuthException catch (e) {
      String userFriendlyMessage = Autherror().mapAuthErrorToUserMessage(e);
      log('Auth Error: ${e.message}, Status: ${e.statusCode}');
      emit(getUserFailureState(error: userFriendlyMessage));
    } catch (e) {
      print('Unexpected error: $e');
      emit(
        getUserFailureState(
          error: "An unexpected error occurred. Please try again.",
        ),
      );
    }
  }

  List<Userentity> userslist = [];
  getAllusers() async {
    try {
      emit(getAllUsersLoadingState());
    userslist = await getallusersusecase.execute();

      emit(getAllUsersSuccessState());
    } on AuthException catch (e) {
      String userFriendlyMessage = Autherror().mapAuthErrorToUserMessage(e);
      log('Auth Error: ${e.message}, Status: ${e.statusCode}');
      emit(getAllUsersFailureState(error: userFriendlyMessage));
    } on Exception catch (e) {
      emit(getAllUsersFailureState(error: e.toString()));
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      // CRITICAL FIX: Cancel stream subscription on logout
      await _usersSubscription?.cancel();
      _usersSubscription = null;
    await  logoutusecase.execute();

      uid = null;

      print("Logout successful");
    } catch (e) {
      print("Logout error: $e");
    }
  }
  // CRITICAL FIX: Add dispose method to cancel subscriptions
  @override
  Future<void> close() async {
    await _usersSubscription?.cancel();
    emailcontroller.dispose();
    passcontroller.dispose();
    return super.close();
  }
}
