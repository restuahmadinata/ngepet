import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngepet/app/common/widgets/button1.dart';
import 'package:ngepet/app/common/widgets/button2.dart';
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

                // --- 2. DUMMY TEXT (Headline Medium) ---
                Text(
                  "Let's start meeting cute pets at NgePet!",
                  textAlign: TextAlign.center,
                  // Using headlineSmall (H3) from TextTheme
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                const SizedBox(height: 40),

                // --- 3. BUTTONS (Login & Register) ---

                // Button 1: Login (Primary Action)
                Button1(
                  text: 'LOGIN',
                  onPressed: controller.goToLogin,
                ),
                const SizedBox(height: 16),

                // Button 2: Daftar (Secondary Action)
                Button2(
                  text: 'REGISTER',
                  onPressed: controller.goToRegister,
                ),
                const SizedBox(height: 24),

                // --- 4. DIVIDER ---
                Row(
                  children: [
                    Expanded(child: Divider(color: colorScheme.outline)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colorScheme.outline)),
                  ],
                ),
                const SizedBox(height: 24),


                // Button 3: Daftar (Secondary Action)
                Button2(
                  text: 'REGISTER AS SHELTER',
                  onPressed: controller.goToShelterRegistration,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
