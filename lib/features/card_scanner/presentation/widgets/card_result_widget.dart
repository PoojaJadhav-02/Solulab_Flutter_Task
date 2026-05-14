import 'package:flutter/material.dart';

import '../../domain/entities/card_details.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/image_preview_widget.dart';
import '../../../../core/widgets/info_row_widget.dart';
import '../../../../core/widgets/scan_action_button.dart';

/// Displays the parsed card details in a visually rich result card.
class CardResultWidget extends StatelessWidget {
  const CardResultWidget({
    super.key,
    required this.cardDetails,
    required this.onScanAgain,
    this.imagePath,
  });

  final CardDetails cardDetails;
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
          // ── Scanned image preview ──────────────────────────────────────
          if (imagePath != null) ...[
            ImagePreviewWidget(imagePath: imagePath!, height: 180),
            const SizedBox(height: 20),
          ],

          // ── Visual card widget ─────────────────────────────────────────
          _CardVisual(cardDetails: cardDetails),

          const SizedBox(height: 24),

          // ── Extracted details card ─────────────────────────────────────
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
                // Header
                Row(
                  children: [
                    const Icon(Icons.credit_card_rounded,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.cardResultTitle,
                      style: theme.textTheme.titleLarge,
                    ),
                    const Spacer(),
                    // Luhn badge
                    _LuhnBadge(isValid: cardDetails.isLuhnValid),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                const SizedBox(height: 8),

                // ── Card number ──────────────────────────────────────────
                InfoRowWidget(
                  label: AppStrings.cardNumber,
                  value: cardDetails.maskedCardNumber ??
                      AppStrings.notDetected,
                  icon: Icons.numbers_rounded,
                  copyable: cardDetails.maskedCardNumber != null,
                ),

                // ── Card holder ──────────────────────────────────────────
                InfoRowWidget(
                  label: AppStrings.cardHolder,
                  value: cardDetails.cardHolderName ?? AppStrings.notDetected,
                  icon: Icons.person_rounded,
                  copyable: cardDetails.cardHolderName != null,
                ),

                // ── Expiry ────────────────────────────────────────────────
                InfoRowWidget(
                  label: AppStrings.cardExpiry,
                  value: cardDetails.expiryDate ?? AppStrings.notDetected,
                  icon: Icons.calendar_today_rounded,
                ),

                // ── Network ───────────────────────────────────────────────
                InfoRowWidget(
                  label: AppStrings.cardNetwork,
                  value: cardDetails.cardNetwork.label,
                  icon: Icons.hub_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Scan again ─────────────────────────────────────────────────
          ScanActionButton(
            label: AppStrings.scanAgain,
            icon: Icons.document_scanner_rounded,
            onTap: onScanAgain,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Visual card widget ────────────────────────────────────────────────────────

class _CardVisual extends StatelessWidget {
  const _CardVisual({required this.cardDetails});
  final CardDetails cardDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: _networkGradient(cardDetails.cardNetwork),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _networkGradient(cardDetails.cardNetwork)
                .first
                .withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // BG circles
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
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // EMV Chip
                    Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Network badge
                    Text(
                      cardDetails.cardNetwork.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  cardDetails.maskedCardNumber ?? '•••• •••• •••• ••••',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CARD HOLDER',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 9,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 3),
                        Text(
                          cardDetails.cardHolderName ?? '—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('VALID THRU',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 9,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 3),
                        Text(
                          cardDetails.expiryDate ?? '—/—',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  List<Color> _networkGradient(CardNetwork network) {
    switch (network) {
      case CardNetwork.visa:
        return [const Color(0xFF1565C0), const Color(0xFF0D47A1)];
      case CardNetwork.mastercard:
        return [const Color(0xFFEB5757), const Color(0xFFF6A623)];
      case CardNetwork.americanExpress:
        return [const Color(0xFF1A7F64), const Color(0xFF0D5C48)];
      case CardNetwork.rupay:
        return [const Color(0xFF6A1B9A), const Color(0xFF4A148C)];
      case CardNetwork.discover:
        return [const Color(0xFFE65100), const Color(0xFFBF360C)];
      case CardNetwork.maestro:
        return [const Color(0xFF00838F), const Color(0xFF006064)];
      case CardNetwork.unknown:
        return [const Color(0xFF37474F), const Color(0xFF263238)];
    }
  }
}

// ── Luhn badge ────────────────────────────────────────────────────────────────

class _LuhnBadge extends StatelessWidget {
  const _LuhnBadge({required this.isValid});
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isValid
            ? AppTheme.successColor.withValues(alpha: 0.15)
            : AppTheme.errorColor.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.verified_rounded : Icons.cancel_rounded,
            size: 12,
            color: isValid ? AppTheme.successColor : AppTheme.errorColor,
          ),
          const SizedBox(width: 4),
          Text(
            isValid ? 'Luhn ✓' : 'Luhn ✗',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isValid ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
