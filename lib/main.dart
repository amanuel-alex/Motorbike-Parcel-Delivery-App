import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_wrapper.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/design_gallery_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(showOnboarding: showOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zipp&Go',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Start with Onboarding if first time, else AuthWrapper
      home: showOnboarding ? const OnboardingScreen() : const AuthWrapper(), 
      routes: {
        '/gallery': (context) => const DesignGalleryScreen(),
        '/auth': (context) => const AuthWrapper(),
      },
    );
  }
}
