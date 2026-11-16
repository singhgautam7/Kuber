import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/advanced_history/providers/ah_providers.dart';
import 'package:kuber/features/advanced_history/query/query_ast.dart';
import 'package:kuber/features/advanced_history/query/query_parser.dart';
import 'package:kuber/features/advanced_history/widgets/token_field/operator_bar.dart';
import 'package:kuber/features/advanced_history/widgets/token_field/token_filter_controller.dart';
import 'package:kuber/features/advanced_history/widgets/token_field/token_filter_field.dart';
import 'package:kuber/l10n/app_localizations.dart';

import '../../../helpers/golden_fonts.dart';

const s = kTokenSentinel;

Future<void> pumpField(
  WidgetTester t,
  TokenFilterController c, {
  List<AhSuggestion> suggestions = const [],
  bool bar = true,
}) async {
  await loadGoldenFonts();
  await t.pumpWidget(ProviderScope(
    overrides: [
      ahSuggestionsProvider.overrideWith((ref, q) async => suggestions),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            TokenFilterField(
              controller: c,
              money: AppFormatter().formatCurrency,
              placeholder: 'Type a filter or pick a field',
            ),
            if (bar) OperatorBar(controller: c),
          ]),
        ),
      ),
    ),
  ));
  await settleFonts(t);
}

Finder get input => find.byKey(const ValueKey('ahf-input'));

/// Compact description of an item list, e.g. `T(category:food) and (`.
String d(List<QueryItem> l) => l.map((i) => switch (i) {
      TokenItem t => t.text,
      JoinerItem j => j.isOr ? 'or' : 'and',
      NotItem _ => 'not',
      OpenItem _ => '(',
      CloseItem _ => ')',
    }).join(' ');

TokenFilterController ctl(String text) =>
    TokenFilterController(items: tokenize(text));
