import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/services/ocr_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';

// Card scanner DI
import 'features/card_scanner/data/models/card_parser_service.dart';
import 'features/card_scanner/data/repositories/card_scanner_repository_impl.dart';
import 'features/card_scanner/domain/usecases/scan_card_usecase.dart';
import 'features/card_scanner/presentation/provider/card_scanner_provider.dart';

// Passbook scanner DI
import 'features/passbook_scanner/data/models/passbook_parser_service.dart';
import 'features/passbook_scanner/data/repositories/passbook_scanner_repository_impl.dart';
import 'features/passbook_scanner/domain/usecases/scan_passbook_usecase.dart';
import 'features/passbook_scanner/presentation/provider/passbook_scanner_provider.dart';

// Shared
import 'features/shared/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait orientation for consistent card scanning UX
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const OcrScannerApp());
}

/// Root widget of the application.
///
/// Sets up the dependency injection tree via [MultiProvider] at the top level
/// so that providers are accessible throughout the entire widget tree.
///
/// Dependency Graph (bottom → top):
///   OcrService → CardParserService → CardScannerRepositoryImpl
///   → ScanCardUseCase → CardScannerProvider
///
///   OcrService → PassbookParserService → PassbookScannerRepositoryImpl
///   → ScanPassbookUseCase → PassbookScannerProvider
class OcrScannerApp extends StatelessWidget {
  const OcrScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared OCR service instance (one TextRecognizer is enough)
    final ocrService = OcrService();

    return MultiProvider(
      providers: [
        // ── Card Scanner Provider ──────────────────────────────────────
        ChangeNotifierProvider<CardScannerProvider>(
          create: (_) => CardScannerProvider(
            scanCardUseCase: ScanCardUseCase(
              CardScannerRepository(
                ocrService: ocrService,
                parserService: const CardParserService(),
              ),
            ),
          ),
        ),

        // ── Passbook Scanner Provider ──────────────────────────────────
        ChangeNotifierProvider<PassbookScannerProvider>(
          create: (_) => PassbookScannerProvider(
            scanPassbookUseCase: ScanPassbookUseCase(
              PassbookScannerRepository(
                ocrService: ocrService,
                parserService: const PassbookParserService(),
              ),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark, // Default to dark for premium feel
        home: const HomeScreen(),
      ),
    );
  }
}
