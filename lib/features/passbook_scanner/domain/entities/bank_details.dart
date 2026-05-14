/// Immutable entity representing the structured data extracted from a
/// bank passbook or account document scan.
///
/// All fields are nullable because OCR may not detect every field reliably.
class BankDetails {
  const BankDetails({
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    this.bankName,
  });

  /// Full name of the account holder.
  final String? accountHolderName;

  /// Bank account number (9–18 digits typically in India).
  final String? accountNumber;

  /// Indian Financial System Code, format: 4-letter bank code + 0 + 6 chars.
  /// Example: "SBIN0001234"
  final String? ifscCode;

  /// Name of the bank (may be inferred from IFSC prefix).
  final String? bankName;

  // ── Computed Properties ──────────────────────────────────────────────────

  /// Returns true only when we have at least one meaningful data field.
  bool get hasData =>
      accountHolderName != null ||
      accountNumber != null ||
      ifscCode != null ||
      bankName != null;

  /// Formats the account number with spaces every 4 digits for readability.
  String? get formattedAccountNumber {
    if (accountNumber == null || accountNumber!.isEmpty) return null;
    final digits = accountNumber!.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  // ── Equality / Copy ──────────────────────────────────────────────────────

  BankDetails copyWith({
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
  }) {
    return BankDetails(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankDetails &&
          accountHolderName == other.accountHolderName &&
          accountNumber == other.accountNumber &&
          ifscCode == other.ifscCode &&
          bankName == other.bankName;

  @override
  int get hashCode =>
      Object.hash(accountHolderName, accountNumber, ifscCode, bankName);

  @override
  String toString() =>
      'BankDetails(holder: $accountHolderName, account: $accountNumber, '
      'ifsc: $ifscCode, bank: $bankName)';
}
