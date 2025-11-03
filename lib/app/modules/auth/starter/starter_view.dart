import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngepet/app/widgets/button1.dart'; 
import 'package:ngepet/app/widgets/button2.dart'; 
import 'starter_controller.dart'; 

class StarterView extends GetView<StarterController> {
  const StarterView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 1. LOGO APLIKASI ---
                Image.asset(
                  'assets/images/logo_ngepet_with_pet.png', 
                  width: 400,
                  height: 300,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.pets,
                        size: 100,
                        color: colorScheme.primary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // --- 2. TEKS DUMMY (Headline Medium) ---
                Text(
                  "Ayo, mulai kenalan dengan para pet lucu di NgePet!",
                  textAlign: TextAlign.center,
                  // Menggunakan headlineSmall (H3) dari TextTheme
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // --- 3. BUTTONS (Masuk & Daftar) ---
                
                // Button 1: Masuk (Primary Action)
                Button1(
                  text: 'MASUK',
                  onPressed: () {
                    controller.goToLogin(); 
                  },
                ),
                const SizedBox(height: 16),

                // Button 2: Daftar (Secondary Action)
                Button2(
                  text: 'DAFTAR',
                  onPressed: () {
                    controller.goToRegister(); 
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}