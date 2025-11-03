import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart'; // Untuk konsistensi font

class Button1 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;

  const Button1({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      
      // --- STYLING BUTTON ---
      style: ElevatedButton.styleFrom(
        // 1. Warna (Fill)
        backgroundColor: AppColors.primary, // Menggunakan Green/green-500
        foregroundColor: AppColors.textLight, // Warna teks (diambil dari AppColors)
        disabledBackgroundColor: AppColors.neutral300, // Abu-abu saat disabled
        disabledForegroundColor: AppColors.neutral600, 
        
        // 2. Bentuk dan Radius
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Corner radius: 8
        ),
        
        // 3. Padding (Contoh Padding Default)
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        
        // 4. Text Style (Menggunakan BodyLarge dari Theme untuk konsistensi)
        textStyle: GoogleFonts.poppins(
          fontSize: 16, 
          fontWeight: FontWeight.w600, // Memberikan sedikit penekanan pada tombol
        ),
        
        elevation: 0, // Biasanya tombol Material 3 tidak memiliki shadow/elevation
      ),
      
      child: Text(text),
    );
  }
}