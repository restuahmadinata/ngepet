import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngepet/app/common/widgets/button1.dart';
import 'package:ngepet/app/common/widgets/text_field.dart';
import 'register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // Akses Theme Data
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface, size: 28),
          onPressed: () => Get.back(),
          iconSize: 28,
          padding: const EdgeInsets.all(12),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Logonya NgePet
                Image.asset(
                  'assets/images/logo_ngepet.png',
                  width: 200,
                  height: 200,
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
                const SizedBox(height: 16),

                Text(
                  "Register",
                  textAlign: TextAlign.center,
                  // Menggunakan headlineSmall (H3) dari TextTheme
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // 2. Input Nama - MENGGUNAKAN CustomTextField
                CustomTextField(
                  controller: controller.nameController,
                  keyboardType: TextInputType.name,
                  labelText: 'Nama',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Input Email - MENGGUNAKAN CustomTextField
                CustomTextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  labelText: 'Email',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Input Password - MENGGUNAKAN CustomTextField
                Obx(
                  () => CustomTextField(
                    controller: controller.passwordController,
                    obscureText: controller.isPasswordHidden.value,
                    labelText: 'Password',
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: colorScheme.onSurfaceVariant,
                    ),

                    // Logika Icon Mata dimasukkan ke suffixIcon
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        controller.isPasswordHidden.toggle();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Konfirmasi Password - MENGGUNAKAN CustomTextField
                Obx(
                  () => CustomTextField(
                    controller: controller.confirmPasswordController,
                    obscureText: controller.isConfirmPasswordHidden.value,
                    labelText: 'Konfirmasi Password',
                    keyboardType: TextInputType.visiblePassword,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: colorScheme.onSurfaceVariant,
                    ),

                    // Logika Icon Mata dimasukkan ke suffixIcon
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordHidden.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        controller.isConfirmPasswordHidden.toggle();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 6. Register Button dengan Loading Indicator
                Obx(
                  () => controller.isLoading.value
                      ? Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sedang mendaftar...',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Button1(text: 'REGISTER', onPressed: controller.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
