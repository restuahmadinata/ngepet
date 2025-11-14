import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngepet/app/common/widgets/button1.dart';
import 'package:ngepet/app/common/widgets/text_field.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

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
                  "Login",
                  textAlign: TextAlign.center,
                  // Using headlineSmall (H3) from TextTheme
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // 2. Email Input - USING CustomTextField
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

                // 3. Password Input - USING CustomTextField
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

                // Lupa Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Obx(
                    () => TextButton(
                      onPressed: controller.isLoading.value 
                          ? null 
                          : controller.forgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: controller.isLoading.value 
                              ? colorScheme.outline 
                              : colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 4. Login Button dengan Loading Indicator
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
                                'Logging in...',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Button1(text: 'LOGIN', onPressed: controller.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
