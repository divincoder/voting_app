import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voting_app/constants/keys.dart';
import 'package:voting_app/core/app/app.locator.dart';
import 'package:voting_app/core/app_utils.dart';
import 'package:voting_app/core/voting_app_viewmodel.dart';
import 'package:voting_app/features/forgot_password/view/forgot_password_view.dart';
import 'package:voting_app/features/home/view/home_view.dart';
import 'package:voting_app/features/reset_password/view/reset_password_view.dart';
import 'package:voting_app/firebase/authentication.dart';
import 'package:voting_app/util/notification.dart';

class LoginViewModel extends VotingAppViewmodel {
  /// Dependency injection =====================================================
  final authentication = locator<Authentication>();

  /// States and variables =====================================================

  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool? _isNewUser;
  bool? get isNewUser => _isNewUser;
  set isNewUser(bool? newValue) {
    _isNewUser = newValue;
    notifyListeners();
  }

  /// ==========================================================================

  /// Methods ==================================================================

  onReady() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isNewUser = prefs.getBool(Keys.isFirstTime);
  }

  toForgotPassword() {
    navigationService.navigateToView(const ForgotPasswordView());
  }

  toResetPassword() {
    navigationService.navigateToView(const ResetPasswordView());
  }

  toHome() {
    navigationService.navigateToView(const HomeView());
  }

  login() async {
    bool isLoggedIn = await authentication.login(
      email: emailController.text,
      password: passwordController.text,
    );

    if (isLoggedIn) {
      if (!authentication.checkUserVerificationStatus()) {
        AppNotification.error(
            error:
                "Email is not verified!\nCheck your email inbox for your verification message");
        return;
      }
      bool? isFirstTimeUser = isNewUser ?? db.currentUser?.isFirstTime;
      // Checks if user is a regular user
      if (isFirstTimeUser == null || isFirstTimeUser == false) {
        logger.d("This is a regular user");
        emailController.clear();
        passwordController.clear();
        toHome();
      }
      // User is a new user
      else {
        emailController.clear();
        passwordController.clear();
        logger.d("This is a new user");
        toResetPassword();
      }
    } else {
      // AppNotification.notify(
      //     notificationMessage: "Register an account to vote");
      return;
    }
  }
}
