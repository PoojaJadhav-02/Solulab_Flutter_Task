import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/card_scanner_provider.dart';
import '../widgets/card_result_widget.dart';
import '../widgets/card_scanner_idle_widget.dart';
import '../../../../core/widgets/scan_loading_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/constants/app_strings.dart';

/// The main Card Scanner screen.
///
/// Uses [Consumer] to rebuild only when [CardScannerProvider] notifies.
/// Renders a different child widget for each [ScanState]:
///   idle     → [CardScannerIdleWidget]
///   loading  → [ScanLoadingWidget]
///   success  → [CardResultWidget]
///   error    → [ErrorStateWidget]
class CardScannerScreen extends StatelessWidget {
  const CardScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cardScannerTitle),
        centerTitle: false,
        actions: [
          // Reset button — only visible when not idle
          Consumer<CardScannerProvider>(
            builder: (_, provider, __) {
              if (provider.state == ScanState.idle) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Scan again',
                onPressed: provider.reset,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CardScannerProvider>(
        builder: (context, provider, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _buildBody(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CardScannerProvider provider) {
    switch (provider.state) {
      case ScanState.idle:
        return const CardScannerIdleWidget(key: ValueKey('idle'));

      case ScanState.picking:
        return ScanLoadingWidget(
          key: const ValueKey('picking'),
          statusLabel: 'Opening camera…',
        );

      case ScanState.extracting:
        return ScanLoadingWidget(
          key: const ValueKey('extracting'),
          statusLabel: AppStrings.extracting,
        );

      case ScanState.parsing:
        return ScanLoadingWidget(
          key: const ValueKey('parsing'),
          statusLabel: AppStrings.processing,
        );

      case ScanState.success:
        return CardResultWidget(
          key: const ValueKey('success'),
          cardDetails: provider.cardDetails!,
          imagePath: provider.scannedImagePath,
          onScanAgain: provider.reset,
        );

      case ScanState.error:
        return ErrorStateWidget(
          key: const ValueKey('error'),
          message: provider.errorMessage ?? AppStrings.invalidScan,
          actionLabel: AppStrings.tryAgain,
          onAction: provider.reset,
        );
    }
  }
}
