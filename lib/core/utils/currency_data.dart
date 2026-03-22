class KuberCurrency {
  final String code;
  final String name;
  final String symbol;

  const KuberCurrency({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

const kCurrencies = <KuberCurrency>[
  KuberCurrency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  KuberCurrency(code: 'USD', name: 'US Dollar', symbol: '\$'),
  KuberCurrency(code: 'EUR', name: 'Euro', symbol: '€'),
  KuberCurrency(code: 'GBP', name: 'British Pound', symbol: '£'),
  KuberCurrency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  KuberCurrency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
  KuberCurrency(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  KuberCurrency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
  KuberCurrency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
  KuberCurrency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
  KuberCurrency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr'),
  KuberCurrency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr'),
  KuberCurrency(code: 'DKK', name: 'Danish Krone', symbol: 'kr'),
  KuberCurrency(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
  KuberCurrency(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$'),
  KuberCurrency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM'),
  KuberCurrency(code: 'THB', name: 'Thai Baht', symbol: '฿'),
  KuberCurrency(code: 'PHP', name: 'Philippine Peso', symbol: '₱'),
  KuberCurrency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp'),
  KuberCurrency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
  KuberCurrency(code: 'MXN', name: 'Mexican Peso', symbol: 'MX\$'),
  KuberCurrency(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
  KuberCurrency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ'),
  KuberCurrency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼'),
  KuberCurrency(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
];

KuberCurrency currencyFromCode(String code) {
  return kCurrencies.firstWhere(
    (c) => c.code == code,
    orElse: () => kCurrencies.first,
  );
}
