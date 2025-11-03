import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase (dengan error handling)
  try {
    // Uncomment baris di bawah jika sudah setup Firebase
    // await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NgePet App',
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}