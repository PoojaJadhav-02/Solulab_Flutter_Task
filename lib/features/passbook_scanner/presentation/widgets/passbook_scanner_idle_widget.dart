import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/passbook_scanner_provider.dart';
import '../../../../core/widgets/scan_action_button.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';

class PassbookScannerIdleWidget extends StatelessWidget {
  const PassbookScannerIdleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PassbookScannerProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),

          _PassbookIllustration(),

          const SizedBox(height: 36),

          Text(
            'Scan Your Passbook',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Open your bank passbook to the account details page.\n'
            'Ensure all text is clearly visible and in focus.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 36),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _FeatureChip(label: 'Account Number'),
              _FeatureChip(label: 'IFSC Code'),
              _FeatureChip(label: 'Account Holder'),
              _FeatureChip(label: 'Bank Name'),
            ],
          ),

          const SizedBox(height: 40),

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

class _PassbookIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 190,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4AA), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -25,
            right: -25,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    const Text(
                      'BANK PASSBOOK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildRow('Account Holder', 'RAMESH KUMAR'),
                const SizedBox(height: 8),
                _buildRow('Account No.', '•••• •••• 7890'),
                const SizedBox(height: 8),
                _buildRow('IFSC Code', 'SBIN0001234'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  letterSpacing: 0.3)),
        ),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.accentColor.withValues(alpha: 0.12),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.accentColor,
        ),
      ),
    );
  }
}
