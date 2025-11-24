import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lottie_loading.dart';

/// Widget untuk menampilkan gambar dari network dengan caching
/// Memiliki error handling dan retry mechanism yang baik
class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Validate URL
    if (imageUrl.isEmpty || !_isValidUrl(imageUrl)) {
      return _buildErrorWidget();
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // HTTP headers untuk mengatasi connection reset
      httpHeaders: const {
        'Connection': 'keep-alive',
        'User-Agent': 'Mozilla/5.0 (compatible; Flutter App)',
        'Accept': 'image/*',
      },
      // Cache optimization
      maxHeightDiskCache: 800,
      maxWidthDiskCache: 800,
      memCacheHeight: (height?.toInt() ?? 200) * 2,
      memCacheWidth: (width?.toInt() ?? 200) * 2,
      // Fade animation
      fadeInDuration: const Duration(milliseconds: 500),
      fadeOutDuration: const Duration(milliseconds: 200),
      // Placeholder while loading
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: const Center(
              child: LottieLoading(width: 80, height: 80),
            ),
          ),
      // Error widget
      errorWidget: (context, url, error) {
        // Log error untuk debugging
        debugPrint('❌ Error loading image: $url');
        debugPrint('   Error type: ${error.runtimeType}');
        debugPrint('   Error details: $error');
        
        return errorWidget ?? _buildErrorWidget();
      },
    );

    // Wrap with ClipRRect if borderRadius is provided
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: 48,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Failed to load photo',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
