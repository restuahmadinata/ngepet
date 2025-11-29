import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ngepet/app/common/widgets/button1.dart';
import 'package:ngepet/app/common/widgets/text_field.dart';
import 'package:ngepet/app/theme/app_colors.dart';
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
                  // Using headlineSmall (H3) from TextTheme
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // 2. Name Input - USING CustomTextField
                CustomTextField(
                  controller: controller.nameController,
                  keyboardType: TextInputType.name,
                  labelText: 'Name',
                ),
                const SizedBox(height: 16),

                // 3. Email Input - USING CustomTextField
                CustomTextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  labelText: 'Email',
                ),
                const SizedBox(height: 16),

                // 4. Password Input - USING CustomTextField
                Obx(
                  () => CustomTextField(
                    controller: controller.passwordController,
                    obscureText: controller.isPasswordHidden.value,
                    labelText: 'Password',
                    keyboardType: TextInputType.visiblePassword,

                    // Logika Icon Mata dimasukkan ke suffixIcon
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.neutral600,
                      ),
                      onPressed: () {
                        controller.isPasswordHidden.toggle();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Confirm Password - USING CustomTextField
                Obx(
                  () => CustomTextField(
                    controller: controller.confirmPasswordController,
                    obscureText: controller.isConfirmPasswordHidden.value,
                    labelText: 'Confirm Password',
                    keyboardType: TextInputType.visiblePassword,

                    // Eye Icon logic added to suffixIcon
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordHidden.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.neutral600,
                      ),
                      onPressed: () {
                        controller.isConfirmPasswordHidden.toggle();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 6. Register Button dengan Loading Indicator
                Obx(() => Button1(
                  text: 'REGISTER',
                  onPressed: controller.register,
                  isLoading: controller.isLoading.value,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
