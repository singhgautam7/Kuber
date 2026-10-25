// Real fonts for image goldens: the Material icon font from the Flutter SDK
// (otherwise icons render as boxes) and the bundled Inter weights, loaded by
// google_fonts itself from assets/google_fonts (no network).
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

bool _iconsLoaded = false;

Future<void> loadGoldenFonts() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  if (_iconsLoaded) return;
  final root = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final file = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (file.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
    await loader.load();
  }
  _iconsLoaded = true;
}

/// Pumps until google_fonts has registered every Inter weight it was asked
/// for (they load asynchronously from the bundled assets).
Future<void> settleFonts(WidgetTester t) async {
  await t.runAsync(() => GoogleFonts.pendingFonts());
  await t.pump();
}
