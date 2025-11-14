import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class Button1 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;

  const Button1({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,

      // --- STYLING BUTTON ---
      style: ElevatedButton.styleFrom(
        // 1. Color (Fill)
        backgroundColor: AppColors.primary, // Using Green/green-500
        foregroundColor:
            AppColors.textLight, // Text color (taken from AppColors)
        disabledBackgroundColor: AppColors.neutral300, // Gray when disabled
        disabledForegroundColor: AppColors.neutral600,

        // 2. Shape and Radius
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Corner radius: 8
        ),

        // 3. Padding (Example Default Padding)
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

        // 4. Text Style (Using BodyLarge from Theme for consistency)
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight:
              FontWeight.w600, // Give slight emphasis to the button
        ),

        elevation:
            0, // Material 3 buttons usually don't have shadow/elevation
      ),

      child: Text(text),
    );
  }
}
