import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngepet/app/widgets/button1.dart';
import 'package:ngepet/app/widgets/text_field.dart';
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
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Get.back(),
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
                  // Menggunakan headlineSmall (H3) dari TextTheme
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // 2. Input Email - MENGGUNAKAN CustomTextField
                CustomTextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),

                // 3. Input Password - MENGGUNAKAN CustomTextField
                Obx(() => CustomTextField(
                  controller: controller.passwordController,
                  obscureText: controller.isPasswordHidden.value,
                  labelText: 'Password',
                  keyboardType: TextInputType.visiblePassword,
                  prefixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
                  
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
                )),
                const SizedBox(height: 16),

                // Lupa Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: controller.forgotPassword,
                    child: Text(
                      'Lupa Password?',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 32),


                // 4. Login Button
                Button1(
                  text: 'LOGIN',
                  onPressed: controller.login,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}