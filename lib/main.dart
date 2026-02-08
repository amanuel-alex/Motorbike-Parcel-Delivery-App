import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_wrapper.dart';
import 'screens/design_gallery_screen.dart';

// IMPORTANT: Run 'flutterfire configure' to generate this file if you haven't yet.
// import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
    // Handle the case where firebase_options.dart is missing or config is wrong
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motorbike Parcel Delivery App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Change this to AuthWrapper() to start the real app flow
      // Keeping DesignGalleryScreen for now so you can still preview screens
      home: const AuthWrapper(), 
      routes: {
        '/gallery': (context) => const DesignGalleryScreen(),
      },
    );
  }
}
