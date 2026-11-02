import 'package:flutter/material.dart';

import 'core/di/app_dependencies.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_gate.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/profile/screens/change_password_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/profile_screen.dart';

/// кореневий віджет застосунку gardenplan
class GardenPlanApp extends StatelessWidget {
  const GardenPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GardenPlan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.root,
      // firebase analytics відстежує переходи між іменованими маршрутами
      navigatorObservers: context.analytics.navigatorObservers,
      // таблиця маршрутів: назва екрана -> функція яка його створює
      routes: {
        AppRoutes.root: (_) => const AuthGate(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.editProfile: (_) => const EditProfileScreen(),
        AppRoutes.changePassword: (_) => const ChangePasswordScreen(),
      },
    );
  }
}
