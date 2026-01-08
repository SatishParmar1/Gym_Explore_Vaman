import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymexplore/presentation/blocs/diet/diet_bloc.dart';
import 'package:gymexplore/presentation/blocs/workout/workout_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backend/backend.dart';
import 'core/theme/app_theme.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/blocs/dashboard/dashboard_bloc.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/pages/onboarding/feature_showcase_page.dart';
import 'presentation/pages/dashboard/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase backend
  await BackendConfig.initialize(
    enableLogging: true, // Set to false in production
  );
  
  // Setup dependency injection
  BackendProviders.setup();
  
  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF121212),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  // Check if this is first launch
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  
  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => DashboardBloc()),
        BlocProvider(create: (context) => DietBloc()),
        BlocProvider(create: (context) => WorkoutBloc()),
      ],
      child: MaterialApp(
        title: 'FitSync',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark, // Force dark theme for Iron & Rust
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return const SplashPage();
            } else if (state is AuthAuthenticated || state is AuthGuestMode) {
              // Show feature showcase for first-time users, otherwise dashboard
              return hasSeenOnboarding
                  ? const DashboardPage()
                  : const FeatureShowcasePage();
            }
            return const SplashPage();
          },
        ),
      ),
    );
  }
}

