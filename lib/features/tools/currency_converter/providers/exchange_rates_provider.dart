import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRatesResult {
  final Map<String, double> rates;
  final String lastUpdated;
  final bool isStale;

  const ExchangeRatesResult({
    required this.rates,
    required this.lastUpdated,
    required this.isStale,
  });
}

// Full list of currencies supported by frankfurter.app
const kFrankfurterCurrencies = [
  'AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK',
  'EUR', 'GBP', 'HKD', 'HUF', 'IDR', 'ILS', 'INR', 'ISK',
  'JPY', 'KRW', 'MXN', 'MYR', 'NOK', 'NZD', 'PHP', 'PLN',
  'RON', 'SEK', 'SGD', 'THB', 'TRY', 'USD', 'ZAR',
];

final exchangeRatesProvider =
    FutureProvider.family<ExchangeRatesResult, String>((ref, fromCurrency) async {
  const staleDuration = Duration(hours: 24);
  final cacheKey = 'exchange_rates_$fromCurrency';
  final cacheTimeKey = 'exchange_rates_time_$fromCurrency';

  final prefs = await SharedPreferences.getInstance();

  try {
    final response = await http
        .get(Uri.parse('https://api.frankfurter.app/latest?from=$fromCurrency'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final rawRates = (data['rates'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble()));
      rawRates[fromCurrency] = 1.0;

      final fetchTime = DateTime.now().toIso8601String();

      await prefs.setString(cacheKey, json.encode(rawRates));
      await prefs.setString(cacheTimeKey, fetchTime);

      return ExchangeRatesResult(
        rates: rawRates,
        lastUpdated: fetchTime,
        isStale: false,
      );
    }
  } catch (_) {
    // Fall through to cache
  }

  // Load from cache
  final cached = prefs.getString(cacheKey);
  final cachedTime = prefs.getString(cacheTimeKey);

  if (cached != null) {
    final rates = (json.decode(cached) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, (v as num).toDouble()));

    DateTime? fetchedAt;
    if (cachedTime != null) {
      fetchedAt = DateTime.tryParse(cachedTime);
    }

    final isStale = fetchedAt == null ||
        DateTime.now().difference(fetchedAt) > staleDuration;

    return ExchangeRatesResult(
      rates: rates,
      lastUpdated: cachedTime ?? 'Unknown',
      isStale: isStale,
    );
  }

  throw Exception('No exchange rate data available. Check your connection.');
});
