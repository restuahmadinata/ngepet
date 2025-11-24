import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Reusable Lottie loading widget
class LottieLoading extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const LottieLoading({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animation/pet-loading.json',
      width: width ?? 150,
      height: height ?? 150,
      fit: fit,
    );
  }
}
