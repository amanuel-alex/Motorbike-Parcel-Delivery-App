import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Motorbike Parcel Delivery App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFFF9900),
          useMaterial3: true,
          textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF9900),
            primary: const Color(0xFFFF9900),
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/auth': (context) => const AuthWrapper(),
        },
      ),
    );
  }
}
