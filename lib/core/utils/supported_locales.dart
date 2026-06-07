import 'package:flutter/material.dart';

class KuberLanguage {
  final Locale locale;
  final String nativeName;
  final String englishName;

  const KuberLanguage({
    required this.locale,
    required this.nativeName,
    required this.englishName,
  });
}

const List<KuberLanguage> kSupportedLanguages = <KuberLanguage>[
  KuberLanguage(
    locale: Locale('en'),
    nativeName: 'English',
    englishName: 'English',
  ),
  KuberLanguage(
    locale: Locale('hi'),
    nativeName: 'हिन्दी',
    englishName: 'Hindi',
  ),
  KuberLanguage(
    locale: Locale('mr'),
    nativeName: 'मराठी',
    englishName: 'Marathi',
  ),
  KuberLanguage(
    locale: Locale('pa'),
    nativeName: 'ਪੰਜਾਬੀ',
    englishName: 'Punjabi',
  ),
  KuberLanguage(
    locale: Locale('bn'),
    nativeName: 'বাংলা',
    englishName: 'Bengali',
  ),
  KuberLanguage(
    locale: Locale('te'),
    nativeName: 'తెలుగు',
    englishName: 'Telugu',
  ),
  KuberLanguage(
    locale: Locale('ta'),
    nativeName: 'தமிழ்',
    englishName: 'Tamil',
  ),
  KuberLanguage(
    locale: Locale('ml'),
    nativeName: 'മലയാളം',
    englishName: 'Malayalam',
  ),
  KuberLanguage(
    locale: Locale('kn'),
    nativeName: 'ಕನ್ನಡ',
    englishName: 'Kannada',
  ),
];
