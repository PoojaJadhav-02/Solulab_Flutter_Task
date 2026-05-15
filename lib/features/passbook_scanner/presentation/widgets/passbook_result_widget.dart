import 'package:flutter/material.dart';

import '../../domain/entities/bank_details.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/image_preview_widget.dart';
import '../../../../core/widgets/info_row_widget.dart';
import '../../../../core/widgets/scan_action_button.dart';

class PassbookResultWidget extends StatelessWidget {
  const PassbookResultWidget({
    super.key,
    required this.bankDetails,
    required this.onScanAgain,
    this.imagePath,
  });

  final BankDetails bankDetails;
  final VoidCallback onScanAgain;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imagePath != null) ...[
            ImagePreviewWidget(imagePath: imagePath!, height: 180),
            const SizedBox(height: 20),
          ],

          _BankBadge(bankDetails: bankDetails),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_rounded,
                        color: AppTheme.accentColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.passbookResultTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                const SizedBox(height: 8),

                InfoRowWidget(
                  label: AppStrings.accountHolder,
                  value: bankDetails.accountHolderName ?? AppStrings.notDetected,
                  icon: Icons.person_rounded,
                  copyable: bankDetails.accountHolderName != null,
                ),

                InfoRowWidget(
                  label: AppStrings.accountNumber,
                  value: bankDetails.formattedAccountNumber ??
                      AppStrings.notDetected,
                  icon: Icons.numbers_rounded,
                  copyable: bankDetails.accountNumber != null,
                  valueStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),

                InfoRowWidget(
                  label: AppStrings.ifscCode,
                  value: bankDetails.ifscCode ?? AppStrings.notDetected,
                  icon: Icons.code_rounded,
                  copyable: bankDetails.ifscCode != null,
                  valueStyle: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppTheme.accentColor,
                  ),
                ),

                InfoRowWidget(
                  label: AppStrings.bankName,
                  value: bankDetails.bankName ?? AppStrings.notDetected,
                  icon: Icons.account_balance_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          ScanActionButton(
            label: AppStrings.scanAgain,
            icon: Icons.document_scanner_rounded,
            onTap: onScanAgain,
            useGradient: false,
            outlined: false,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}


class _BankBadge extends StatelessWidget {
  const _BankBadge({required this.bankDetails});
  final BankDetails bankDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF00D4AA), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.account_balance_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankDetails.bankName ?? 'Bank Account',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bankDetails.ifscCode != null
                      ? 'IFSC: ${bankDetails.ifscCode}'
                      : 'IFSC not detected',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
