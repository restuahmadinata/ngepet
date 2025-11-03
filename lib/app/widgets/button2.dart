import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class Button2 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;

  const Button2({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil warna teks dasar (Dark Text) dari tema
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = GoogleFonts.poppins(
      fontSize: 16, 
      fontWeight: FontWeight.w600,
    );

    return OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      
      // --- STYLING BUTTON ---
      style: OutlinedButton.styleFrom(
        // 1. Warna Teks (Foreground) - Warna teks tombol harus mengikuti warna stroke
        foregroundColor: AppColors.neutral900, // Warna teks aktif (Hitam/N9)
        disabledForegroundColor: AppColors.neutral500, // Abu-abu saat disabled

        // 2. Bentuk dan Radius
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Corner radius: 8 (Sama dengan Button1)
        ),

        // 3. Stroke (Border) - Ini adalah perbedaan utama dari ElevatedButton
        side: BorderSide(
          color: isEnabled 
              ? AppColors.neutral900 // Stroke: #000000 (Neutral/N9)
              : AppColors.neutral500, // Stroke saat disabled
          width: 1.0, // Weight: 1
        ),
        
        // 4. Padding
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        
        // 5. Text Style (Sama seperti Button1 untuk konsistensi)
        textStyle: textStyle,
      ),
      
      child: Text(text),
    );
  }
}