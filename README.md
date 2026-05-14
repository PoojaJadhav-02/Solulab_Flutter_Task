# OCR Scanner — Flutter Technical Assignment

A production-ready Flutter application that scans **Credit/Debit cards** and **Bank Passbooks** using on-device OCR (Google ML Kit) and custom-built parsing logic — no third-party parsing libraries.

---

## Table of Contents
1. [Features](#features)
2. [Architecture](#architecture)
3. [Project Structure](#project-structure)
4. [Packages Used](#packages-used)
5. [Setup & Run](#setup--run)
6. [Running Tests](#running-tests)
7. [Algorithms Implemented](#algorithms-implemented)
8. [Assumptions](#assumptions)
9. [Known Limitations](#known-limitations)
10. [Future Improvements](#future-improvements)

---

## Features

### 🃏 Card Scanner
| Feature | Detail |
|---|---|
| Image source | Camera or Gallery |
| Card number | Extracted & masked as `XXXX XXXX XXXX 1234` |
| Expiry date | Formats: `MM/YY`, `MM-YY`, `MM/YYYY` |
| Card holder | Extracted from all-caps name line |
| Network detection | Visa, Mastercard, AmEx, Discover, RuPay, Maestro |
| Luhn validation | Manual algorithm — no library |
| OCR correction | `O→0`, `I→1`, `S→5`, `B→8`, etc. |

### 🏦 Passbook Scanner
| Feature | Detail |
|---|---|
| Image source | Camera or Gallery |
| Account number | 9–18 digit extraction; excludes mobile/PIN |
| IFSC code | Strict regex: `[A-Z]{4}0[A-Z0-9]{6}` |
| Account holder | Labeled-line + fallback to all-caps line |
| Bank name | Inferred from IFSC prefix or text match |
| Duplicate deduplication | Automatic |

---

## Architecture

This project follows **Clean Architecture** with strict layer separation:

```
Presentation ──► Domain ◄── Data
   (UI)        (entities,    (repositories,
   (Provider)   use-cases,    parsers,
                interfaces)   OCR service)
```

### Layer Responsibilities

| Layer | Contents | Depends On |
|---|---|---|
| **Domain** | Entities, Repository interfaces, Use-cases | Nothing (pure Dart) |
| **Data** | Repository implementations, Parsers, OCR service | Domain |
| **Presentation** | Screens, Widgets, Providers | Domain |
| **Core** | Theme, Constants, Utils, Shared widgets | Nothing |

### State Management
Provider is used via `ChangeNotifier`. Each feature has its own Provider:
- `CardScannerProvider` — manages card scan state
- `PassbookScannerProvider` — manages passbook scan state

Both follow the same `ScanState` enum lifecycle:
```
idle → picking → extracting → parsing → success / error
```

---

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # Magic numbers, route names
│   │   └── app_strings.dart        # All UI strings (i18n-ready)
│   ├── services/
│   │   ├── ocr_service.dart        # ML Kit OCR wrapper (abstract + impl)
│   │   └── permission_service.dart # Camera/storage permission wrapper
│   ├── theme/
│   │   └── app_theme.dart          # Dark & light Material 3 themes
│   ├── utils/
│   │   ├── enums.dart              # ScanState, ImageSource, CardNetwork
│   │   ├── extensions.dart         # String & List extension methods
│   │   ├── luhn_validator.dart     # Manual Luhn algorithm
│   │   └── ocr_cleaner.dart        # OCR noise correction utilities
│   └── widgets/
│       ├── error_state_widget.dart
│       ├── image_preview_widget.dart
│       ├── info_row_widget.dart
│       ├── scan_action_button.dart
│       └── scan_loading_widget.dart
│
├── features/
│   ├── card_scanner/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── card_parser_service.dart  # Manual card parser
│   │   │   └── repositories/
│   │   │       └── card_scanner_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── card_details.dart         # Immutable entity
│   │   │   ├── repositories/
│   │   │   │   └── i_card_scanner_repository.dart
│   │   │   └── usecases/
│   │   │       └── scan_card_usecase.dart
│   │   └── presentation/
│   │       ├── provider/
│   │       │   └── card_scanner_provider.dart
│   │       ├── screens/
│   │       │   └── card_scanner_screen.dart
│   │       └── widgets/
│   │           ├── card_result_widget.dart
│   │           └── card_scanner_idle_widget.dart
│   │
│   ├── passbook_scanner/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── passbook_parser_service.dart  # Manual passbook parser
│   │   │   └── repositories/
│   │   │       └── passbook_scanner_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── bank_details.dart
│   │   │   ├── repositories/
│   │   │   │   └── i_passbook_scanner_repository.dart
│   │   │   └── usecases/
│   │   │       └── scan_passbook_usecase.dart
│   │   └── presentation/
│   │       ├── provider/
│   │       │   └── passbook_scanner_provider.dart
│   │       ├── screens/
│   │       │   └── passbook_scanner_screen.dart
│   │       └── widgets/
│   │           ├── passbook_result_widget.dart
│   │           └── passbook_scanner_idle_widget.dart
│   │
│   └── shared/
│       └── home_screen.dart
│
└── main.dart                          # DI root via MultiProvider

test/
├── card_scanner/
│   ├── luhn_validator_test.dart       # 16 Luhn tests
│   └── card_parser_test.dart          # 23 card parser tests
└── passbook_scanner/
    └── passbook_parser_test.dart      # 30 passbook parser tests
```

---

## Packages Used

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.2 | State management via ChangeNotifier |
| `google_mlkit_text_recognition` | ^0.13.0 | On-device OCR |
| `camera` | ^0.11.0+2 | Direct camera access |
| `image_picker` | ^1.1.2 | Camera + gallery image selection |
| `permission_handler` | ^11.3.1 | Runtime permissions (camera, storage) |
| `flutter_test` | sdk | Unit testing |
| `flutter_lints` | ^4.0.0 | Code quality linting |

> All OCR is **on-device**. No network calls, no cloud APIs.

---

## Setup & Run

### Prerequisites
- Flutter SDK ≥ 3.5.0
- Android Studio / VS Code
- Android device or emulator (API 21+)

### Steps

```bash
# 1. Clone / navigate to project
cd solulab_company_task

# 2. Install dependencies
flutter pub get

# 3. Run on connected Android device
flutter run

# 4. (Optional) Run in release mode
flutter run --release
```

### Android Permissions Required
The following are declared in `AndroidManifest.xml` and requested at runtime:
- `CAMERA` — for live scanning
- `READ_MEDIA_IMAGES` (API ≥ 33) / `READ_EXTERNAL_STORAGE` (API ≤ 32) — for gallery

---

## Running Tests

```bash
# Run all unit tests
flutter test

# Run with verbose output
flutter test --reporter=expanded

# Run a specific test file
flutter test test/card_scanner/luhn_validator_test.dart
flutter test test/card_scanner/card_parser_test.dart
flutter test test/passbook_scanner/passbook_parser_test.dart
```

**Test results:** 69 tests, 0 failures.

| Test Suite | Count | Coverage |
|---|---|---|
| Luhn Validator | 16 | Valid numbers, invalid numbers, edge cases |
| Card Parser | 23 | Number formats, expiry, holder, network, masks |
| Passbook Parser | 30 | IFSC, account no., holder, bank name, noise |

---

## Algorithms Implemented

### 1. Luhn Algorithm (`luhn_validator.dart`)
Manual implementation of the ISO/IEC 7812 checksum:
1. From the rightmost digit, double every second digit.
2. If doubling produces > 9, subtract 9.
3. Sum all digits.
4. Valid if `sum % 10 == 0`.

```dart
bool isValid(String cardNumber) { ... } // O(n) time, O(1) space
```

### 2. Card Parser (`card_parser_service.dart`)
Extracts structured data from raw OCR text:
- **Card number**: grouped-format regex + compact 13-19 digit scan + OCR fixes
- **Expiry**: MM/YY, MM-YY, MM/YYYY, context-aware (VALID THRU / EXP labels)
- **Holder name**: all-caps multi-word lines, skipping known card keywords
- **Network**: BIN/IIN prefix table (Visa=4, MC=51-55/2221-2720, AmEx=34/37, etc.)

### 3. Passbook Parser (`passbook_parser_service.dart`)
- **IFSC**: strict RBI-format regex `[A-Z]{4}0[A-Z0-9]{6}`
- **Account number**: labeled-line priority → longest digit sequence (9-18 digits, excluding mobiles)
- **Holder name**: labeled-line → all-caps fallback with keyword blocklist
- **Bank name**: IFSC prefix → 4-char code lookup table (26 Indian banks)

### 4. OCR Cleaner (`ocr_cleaner.dart`)
- `O/o → 0`, `I/l/L → 1`, `S → 5`, `B → 8`, `G → 6`, `Z → 2`
- Whitespace normalisation, duplicate line removal, title-case conversion

---

## Assumptions

1. **Indian banking context** — IFSC code format and account number ranges follow RBI specifications.
2. **English-language cards & passbooks only** — ML Kit is configured for Latin script.
3. **Standard card formats** — 13-19 digit numbers; Luhn-validated where applicable.
4. **Portrait orientation** — enforced at startup for consistent camera UX.
5. **On-device only** — no internet permission is requested or used.
6. **Account numbers** — 9-18 digits; Indian mobile numbers (10 digits, 6-9 prefix) are explicitly excluded from account number candidates.

---

## Known Limitations

1. **Embossed cards** — raised lettering on older cards may produce poor OCR accuracy under certain lighting conditions.
2. **Vertical/tilted text** — ML Kit Latin mode works best on horizontally aligned text.
3. **Non-Indian passbooks** — IFSC logic is India-specific; international bank IDs (IBAN, BIC) are not handled.
4. **Handwritten passbooks** — OCR accuracy on handwritten text is significantly lower.
5. **Foil/holographic cards** — reflective surfaces reduce OCR quality; requires good ambient lighting.
6. **Card holder on 2 lines** — if the name is split across lines by the card layout, only the first line may be captured.
7. **iOS not tested** — the app targets Android; iOS requires additional `Info.plist` entries for camera/gallery permissions.

---

## Future Improvements

1. **Image cropping** — let users crop the image before OCR to reduce noise.
2. **Real-time camera overlay** — use `camera` package with live frame analysis for instant detection.
3. **Confidence scoring** — show a confidence percentage for each extracted field.
4. **History / saved scans** — persist results locally using `hive` or `sqflite`.
5. **International passbook support** — add IBAN, BIC/SWIFT, and SORT code parsers.
6. **Localisation** — extract all strings to ARB files for multi-language support.
7. **Accessibility** — add semantic labels to all result widgets.
8. **CI/CD** — add GitHub Actions workflow to run `flutter test` and `flutter analyze` on every PR.
9. **Widget tests** — add widget-level tests for screens using `WidgetTester`.
10. **Dark/Light theme toggle** — expose a UI control to switch themes at runtime.
