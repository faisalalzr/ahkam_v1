import 'package:ahakam_v8/screens/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ahakam_v8/screens/pay.dart';
import 'package:ahakam_v8/keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = publishableKey;
  await Stripe.instance.applySettings();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: 'https://ctxxlxtaizguookwlglo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0eHhseHRhaXpndW9va3dsZ2xvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwODcwMjUsImV4cCI6MjA2MTY2MzAyNX0.gQqhKG3qtEwLRaI_WrGQLfj4dPrCJvI0Yv2KF03OnRg',
  );

  firebase_auth.User? firebaseUser =
      firebase_auth.FirebaseAuth.instance.currentUser;

  runApp(MyApp(user: firebaseUser));
}

class MyApp extends StatelessWidget {
  final firebase_auth.User? user;

  const MyApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFFFFF8F2),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFFF8F2)),
        scaffoldBackgroundColor: Colors.white,
        buttonTheme: ButtonThemeData(buttonColor: Colors.white),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
