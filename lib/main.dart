import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/services/ocr_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_strings.dart';

import 'features/card_scanner/data/models/card_parser_service.dart';
import 'features/card_scanner/data/repositories/card_scanner_repository_impl.dart';
import 'features/card_scanner/domain/usecases/scan_card_usecase.dart';
import 'features/card_scanner/presentation/provider/card_scanner_provider.dart';

import 'features/passbook_scanner/data/models/passbook_parser_service.dart';
import 'features/passbook_scanner/data/repositories/passbook_scanner_repository_impl.dart';
import 'features/passbook_scanner/domain/usecases/scan_passbook_usecase.dart';
import 'features/passbook_scanner/presentation/provider/passbook_scanner_provider.dart';

import 'features/shared/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const OcrScannerApp());
}

class OcrScannerApp extends StatelessWidget {
  const OcrScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<OcrService>(
          create: (_) => OcrService(),
          dispose: (_, service) => service.dispose(),
        ),

        ChangeNotifierProvider<CardScannerProvider>(
          create: (context) => CardScannerProvider(
            scanCardUseCase: ScanCardUseCase(
              CardScannerRepository(
                ocrService: context.read<OcrService>(),
                parserService: const CardParserService(),
              ),
            ),
          ),
        ),

        ChangeNotifierProvider<PassbookScannerProvider>(
          create: (context) => PassbookScannerProvider(
            scanPassbookUseCase: ScanPassbookUseCase(
              PassbookScannerRepository(
                ocrService: context.read<OcrService>(),
                parserService: const PassbookParserService(),
              ),
            ),
          ),
        ),

        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
