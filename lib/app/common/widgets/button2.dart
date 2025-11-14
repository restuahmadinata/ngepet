import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class Button2 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;
  final bool fullWidth;

  const Button2({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get base text color (Dark Text) from theme
    final textStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,

        // --- STYLING BUTTON ---
        style: OutlinedButton.styleFrom(
        // 1. Text Color (Foreground) - Button text should follow stroke color
        foregroundColor: AppColors.neutral900, // Active text color (Black/N9)
        disabledForegroundColor: AppColors.neutral500, // Gray when disabled
        // 2. Shape and Radius
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            8.0,
          ), // Corner radius: 8 (Same as Button1)
        ),

        // 3. Stroke (Border) - This is the main difference from ElevatedButton
        side: BorderSide(
          color: isEnabled
              ? AppColors
                    .neutral900 // Stroke: #000000 (Neutral/N9)
              : AppColors.neutral500, // Stroke when disabled
          width: 1.0, // Weight: 1
        ),

        // 4. Padding
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

        // 5. Text Style (Same as Button1 for consistency)
        textStyle: textStyle,
      ),

      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.neutral900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(text),
              ],
            )
          : Text(text),
      ),
    );
  }
}
