import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Displays a rounded preview of the scanned image with a subtle overlay.
class ImagePreviewWidget extends StatelessWidget {
  const ImagePreviewWidget({
    super.key,
    required this.imagePath,
    this.height = 200,
    this.borderRadius = 16,
  });

  final String imagePath;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          // Image
          Image.file(
            File(imagePath),
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: height,
              color: AppTheme.darkCard,
              child: const Center(
                child: Icon(Icons.broken_image_rounded,
                    color: AppTheme.darkTextSecondary, size: 40),
              ),
            ),
          ),

          // Gradient overlay for label readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),

          // Label
          Positioned(
            bottom: 10,
            left: 12,
            child: Row(
              children: [
                const Icon(Icons.image_rounded,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 5),
                Text(
                  'Scanned Image',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
