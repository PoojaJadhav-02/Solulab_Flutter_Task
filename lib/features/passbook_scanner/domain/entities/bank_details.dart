class BankDetails {
  const BankDetails({
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    this.bankName,
  });

  final String? accountHolderName;

  final String? accountNumber;

  final String? ifscCode;

  final String? bankName;


  bool get hasData =>
      accountHolderName != null ||
      accountNumber != null ||
      ifscCode != null ||
      bankName != null;

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
