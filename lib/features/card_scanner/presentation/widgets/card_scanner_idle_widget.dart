import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/card_scanner_provider.dart';
import '../../../../core/widgets/scan_action_button.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

/// Idle state widget for the card scanner — shown before any scan is initiated.
///
/// Presents the "Use Camera" and "From Gallery" options with a hero card preview.
class CardScannerIdleWidget extends StatelessWidget {
  const CardScannerIdleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CardScannerProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          // ── Hero card illustration ────────────────────────────────────────
          _CreditCardIllustration(),

          const SizedBox(height: 36),

          // ── Instructions ─────────────────────────────────────────────────
          Text(
            'Scan Your Card',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Position your credit or debit card within the frame.\n'
            'Ensure good lighting for accurate OCR.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 36),

          // ── Feature chips ─────────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _FeatureChip(label: 'Card Number'),
              _FeatureChip(label: 'Expiry Date'),
              _FeatureChip(label: 'Card Holder'),
              _FeatureChip(label: 'Luhn Validated'),
              _FeatureChip(label: 'Network Detection'),
            ],
          ),

          const SizedBox(height: 40),

          // ── Action buttons ─────────────────────────────────────────────────
          ScanActionButton(
            label: AppStrings.useCamera,
            icon: Icons.camera_alt_rounded,
            onTap: provider.scanFromCamera,
          ),
          const SizedBox(height: 14),
          ScanActionButton(
            label: AppStrings.useGallery,
            icon: Icons.photo_library_rounded,
            onTap: provider.scanFromGallery,
            useGradient: false,
            outlined: true,
          ),

          const SizedBox(height: 24),

          // ── Privacy note ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded,
                  size: 13,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary),
              const SizedBox(width: 5),
              Text(
                'All processing is on-device. No data is uploaded.',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _CreditCardIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF4F6BF6), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chip + WiFi
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.wifi_rounded,
                        color: Colors.white54, size: 28),
                  ],
                ),

                const Spacer(),

                // Masked number
                const Text(
                  'XXXX  XXXX  XXXX  1234',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                ),

                const SizedBox(height: 16),

                // Name + Expiry
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('CARD HOLDER',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 9,
                                letterSpacing: 1)),
                        SizedBox(height: 3),
                        Text('JOHN DOE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text('VALID THRU',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 9,
                                letterSpacing: 1)),
                        SizedBox(height: 3),
                        Text('12/28',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.primaryColor.withValues(alpha: 0.12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
