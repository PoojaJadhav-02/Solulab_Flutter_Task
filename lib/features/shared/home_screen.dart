import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../card_scanner/presentation/provider/card_scanner_provider.dart';
import '../passbook_scanner/presentation/provider/passbook_scanner_provider.dart';
import '../card_scanner/presentation/screens/card_scanner_screen.dart';
import '../passbook_scanner/presentation/screens/passbook_scanner_screen.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// The application's home / landing screen.
///
/// Presents two feature cards — Card Scanner and Passbook Scanner —
/// each navigating to their respective scan screens with a fresh Provider.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Premium App Bar ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: _AppBarBackground(),
              title: Text(
                AppStrings.appName,
                style: TextStyle(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.lightTextPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Subtitle
                Text(
                  AppStrings.homeSubtitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Feature Cards ───────────────────────────────────────
                _FeatureCard(
                  title: AppStrings.scanCardBtn,
                  description: AppStrings.cardScanDesc,
                  icon: Icons.credit_card_rounded,
                  gradientColors: const [
                    Color(0xFF4F6BF6),
                    Color(0xFF1A237E),
                  ],
                  glowColor: AppTheme.primaryColor,
                  onTap: () => _navigateToCardScanner(context),
                ),

                const SizedBox(height: 20),

                _FeatureCard(
                  title: AppStrings.scanPassbookBtn,
                  description: AppStrings.passbookScanDesc,
                  icon: Icons.account_balance_rounded,
                  gradientColors: const [
                    Color(0xFF00D4AA),
                    Color(0xFF00695C),
                  ],
                  glowColor: AppTheme.accentColor,
                  onTap: () => _navigateToPassbookScanner(context),
                ),

                const SizedBox(height: 40),

                // ── How it works section ────────────────────────────────
                Text('How It Works', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 16),
                const _HowItWorksStep(
                  step: '01',
                  title: 'Capture or Upload',
                  description: 'Use your camera or pick from gallery.',
                ),
                const _HowItWorksStep(
                  step: '02',
                  title: 'OCR Extraction',
                  description: 'On-device ML Kit reads the raw text.',
                ),
                const _HowItWorksStep(
                  step: '03',
                  title: 'Smart Parsing',
                  description: 'Custom algorithms extract structured data.',
                ),
                const _HowItWorksStep(
                  step: '04',
                  title: 'View Results',
                  description: 'Clean, formatted data shown instantly.',
                  isLast: true,
                ),

                const SizedBox(height: 40),

                // ── Footer ────────────────────────────────────────────────
                Center(
                  child: Text(
                    '${AppStrings.appName} v${AppStrings.appVersion}\n'
                    'All OCR processing is on-device',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCardScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CardScannerScreen(),
      ),
    );
  }

  void _navigateToPassbookScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PassbookScannerScreen(),
      ),
    );
  }
}

// ── App Bar Background ────────────────────────────────────────────────────────

class _AppBarBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D0F1A), Color(0xFF161829)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withValues(alpha: 0.07),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                    size: 28,
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

// ── Feature Card ──────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.glowColor,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Color glowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white60, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── How It Works Step ─────────────────────────────────────────────────────────

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({
    required this.step,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  final String step;
  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: Text(
                    step,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 7),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(description,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
