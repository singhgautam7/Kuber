// Real fonts for image goldens: the Material icon font from the Flutter SDK
// (otherwise icons render as boxes) and the bundled variable Inter
// (assets/fonts/InterVariable.ttf), registered as the 'Inter' engine family.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

bool _loaded = false;

Future<void> loadGoldenFonts() async {
  if (_loaded) return;
  final root = Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final file = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (file.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
    await loader.load();
  }
  final inter = FontLoader('Inter')
    ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/InterVariable.ttf').readAsBytesSync())));
  await inter.load();
  _loaded = true;
}

/// Fonts are registered up front, but callers rely on this to also give
/// pending async work (Isar reads) real time to finish, as the old
/// google_fonts `pendingFonts()` wait did. Pumps until no frame is pending
/// or ~600 ms of real time passed.
Future<void> settleFonts(WidgetTester t) async {
  for (var i = 0; i < 6; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await t.pump(const Duration(milliseconds: 100));
  }
}
