import 'dart:async'; // ADD THIS IMPORT
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lastu_pdate_chat_app/src/data/models/usersmodel.dart';
import 'package:lastu_pdate_chat_app/src/services/components.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  
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
      final response = await Supabase.instance.client.auth
          .signInWithPassword(password: password, email: Email);
      
      if (response.user != null) {
        uid = response.user!.id;
        
        // CRITICAL FIX: Save user_id to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', uid!);
        
        print("User ID saved to SharedPreferences: $uid");
      }
        emit(getUserSuccessState());

    } on AuthException catch (e) {
      String userFriendlyMessage = _mapAuthErrorToUserMessage(e);
      log('Auth Error: ${e.message}, Status: ${e.statusCode}');
      emit(getAllUsersFailureState(error: userFriendlyMessage));
    } catch (e) {
      print('Unexpected error: $e');
      emit(
        getAllUsersFailureState(
          error: "An unexpected error occurred. Please try again.",
        ),
      );
    }
  }
  // Helper method to map Supabase errors to user-friendly messages
  String _mapAuthErrorToUserMessage(AuthException error) {
    // Check status code first
    switch (error.statusCode) {
      case '400':
        if (error.message.toLowerCase().contains('invalid') &&
            error.message.toLowerCase().contains('credentials')) {
          return "Invalid email or password. Please check your credentials and try again.";
        }
        if (error.message.toLowerCase().contains('email')) {
          return "Please enter a valid email address.";
        }
        if (error.message.toLowerCase().contains('password')) {
          return "Password is required and must meet the minimum requirements.";
        }
        return "Invalid input. Please check your email and password.";

      case '401':
        return "Invalid email or password. Please try again.";

      case '422':
        return "Account not found or email not verified. Please check your email or sign up.";

      case '429':
        return "Too many login attempts. Please wait a few minutes before trying again.";

      case '500':
        return "Server error. Please try again in a few moments.";

      default:
        // Fallback based on message content
        String message = error.message.toLowerCase();
        if (message.contains('invalid') || message.contains('credentials')) {
          return "Invalid email or password. Please try again.";
        }
        if (message.contains('network') || message.contains('connection')) {
          return "Network error. Please check your internet connection.";
        }
        if (message.contains('user') &&
            message.contains('not') &&
            message.contains('found')) {
          return "No account found with this email. Please sign up first.";
        }
        if (message.contains('email') && message.contains('confirmed')) {
          return "Please verify your email before signing in.";
        }
        return "Login failed. Please check your credentials and try again.";
    }
  }
  List<Usersmodel> userslist = [];
  
  Future<void> getAllUser() async {
    try {
      emit(getAllUsersLoadingState());
      
      // Simple approach: Get data once instead of streaming
      final response = await Supabase.instance.client
          .from('users')
          .select();
      
      userslist.clear();
      for (var row in response) {
        userslist.add(Usersmodel.fromJson(row));
      }
      
      print("All users loaded: ${userslist.length}");
      emit(getAllUsersSuccessState());
      
    } catch (error) {
      print("getAllUser error: $error");
      emit(getAllUsersFailureState(error: error.toString()));
    }
  }
  
  Future<void> logout(BuildContext context) async {
    try {
      // CRITICAL FIX: Cancel stream subscription on logout
      await _usersSubscription?.cancel();
      _usersSubscription = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await Supabase.instance.client.auth.signOut();
      
      // Clear local data
      userslist.clear();
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
