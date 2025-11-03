import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
import '../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  // Metode untuk mendapatkan OutlineInputBorder berdasarkan styling Figma
  OutlineInputBorder _getBorderStyle({required Color color, double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0), // Corner radius 8
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Ambil style BodyLarge (Normal) untuk dijadikan base style
    final baseTextStyle = theme.textTheme.bodyLarge;

    // Definisikan Poppins BodyLarge untuk konsistensi di InputDecoration
    final poppinsBodyLarge = GoogleFonts.poppins(
      fontSize: baseTextStyle?.fontSize,
      fontWeight: baseTextStyle?.fontWeight,
    );
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      
      // 1. Teks yang Diketik (TextFormField Style)
      style: poppinsBodyLarge.copyWith(color: colorScheme.onSurface),
      
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        
        // 2. Label Text Style (saat tidak fokus)
        labelStyle: poppinsBodyLarge.copyWith(color: AppColors.neutral600),
        
        // 3. Hint Text Style
        hintStyle: poppinsBodyLarge.copyWith(color: AppColors.neutral500),
        
        // Icon
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        
        // Fill/Background (Neutral/N1, diasumsikan sebagai colorScheme.surface)
        filled: true,
        fillColor: colorScheme.surface, 
        
        // --- Border States ---
        
        // Default Border (Neutral/N9, Weight 1)
        enabledBorder: _getBorderStyle(color: AppColors.neutral900), 
        border: _getBorderStyle(color: AppColors.neutral900),
        
        // Border saat Error
        errorBorder: _getBorderStyle(color: colorScheme.error),
        focusedErrorBorder: _getBorderStyle(color: colorScheme.error, width: 2.0),
        
        // Focused Border - MENGGUNAKAN PRIMARY COLOR DARI THEME (GREEN)
        focusedBorder: _getBorderStyle(
          color: colorScheme.primary, // Ini adalah AppColors.green500
          width: 2.0,
        ),
      ),
    );
  }
}
