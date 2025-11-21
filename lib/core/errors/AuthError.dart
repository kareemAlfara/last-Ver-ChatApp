import 'package:supabase_flutter/supabase_flutter.dart';

class Autherror {
  // Helper method to map Supabase errors to user-friendly messages
  String mapAuthErrorToUserMessage(AuthException error) {
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

}