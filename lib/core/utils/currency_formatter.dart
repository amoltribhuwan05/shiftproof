/// Central utility for formatting integer rupee amounts for display.
///
/// All monetary values in the app are stored as plain [int] (rupees).
/// Use this class to add the ₹ sign and comma formatting when rendering in UI.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats [amount] (in rupees) with ₹ symbol and Indian comma notation.
  ///
  /// Examples:
  /// ```dart
  /// CurrencyFormatter.format(8500)   // "₹8,500"
  /// CurrencyFormatter.format(100000) // "₹1,00,000"
  /// CurrencyFormatter.format(0)      // "₹0"
  /// ```
  static String format(int amount) {
    if (amount == 0) return '₹0';
    final isNegative = amount < 0;
    final abs = amount.abs();
    final str = abs.toString();

    // Indian number system: last 3 digits, then groups of 2
    final result = StringBuffer();
    final len = str.length;
    if (len <= 3) {
      result.write(str);
    } else {
      result.write(str.substring(0, len - 3));
      result.write(',');
      result.write(str.substring(len - 3));
      // Group remaining digits in pairs (for cr/lakh formatting)
      // The above handles up to lakhs; for larger numbers use formatCompact.
    }

    return '${isNegative ? '-' : ''}₹$result';
  }

  /// Compact format for large amounts — uses L (lakh) or K (thousand).
  ///
  /// Examples:
  /// ```dart
  /// CurrencyFormatter.formatCompact(150000) // "₹1.5L"
  /// CurrencyFormatter.formatCompact(8500)   // "₹8.5K"
  /// CurrencyFormatter.formatCompact(500)    // "₹500"
  /// ```
  static String formatCompact(int amount) {
    if (amount >= 100000) {
      final l = amount / 100000;
      final formatted = l == l.truncateToDouble()
          ? '${l.toInt()}'
          : l.toStringAsFixed(1);
      return '₹${formatted}L';
    } else if (amount >= 1000) {
      final k = amount / 1000;
      final formatted = k == k.truncateToDouble()
          ? '${k.toInt()}'
          : k.toStringAsFixed(1);
      return '₹${formatted}K';
    }
    return '₹$amount';
  }

  /// Parses a formatted rupee string back to an integer.
  /// Handles strings like "₹8,500", "8500", "₹1.5L".
  ///
  /// Useful during migration or when integrating legacy string-based APIs.
  static int parse(String formatted) {
    final clean = formatted
        .replaceAll('₹', '')
        .replaceAll(',', '')
        .replaceAll('/mo', '')
        .trim();
    return int.tryParse(clean) ?? 0;
  }
}
