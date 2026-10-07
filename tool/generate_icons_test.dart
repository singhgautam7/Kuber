import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/shared/widgets/brand_icon.dart';

/// Draws the launcher and splash art from the icon board's folded-leg ₹.
///
/// Not a test: a generator, run as one because `flutter test` is the only place
/// a Flutter canvas exists without a device (copied from PostPurush Android's
/// `tool/generate_icons_test.dart`). The adaptive icon itself is the board's
/// own vector drawables in `res/drawable/`, copied in verbatim and not touched
/// here; these PNGs are the legacy fallback for Android before adaptive icons
/// and the splash art for `flutter_native_splash`.
///
///     flutter test tool/generate_icons_test.dart
///     dart run flutter_native_splash:create
void main() {
  const String res = 'android/app/src/main/res';

  /// Paints [painter] into a square PNG of [size] pixels. Must run inside
  /// `tester.runAsync`: `toImage` needs the real rasteriser.
  Future<Uint8List> render(CustomPainter painter, double size) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    painter.paint(canvas, Size(size, size));
    final ui.Image image = await recorder.endRecording().toImage(
      size.round(),
      size.round(),
    );
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    return bytes!.buffer.asUint8List();
  }

  void write(String path, Uint8List bytes) {
    final File file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
  }

  testWidgets('draws the legacy launcher icon', (WidgetTester tester) async {
    // Android before 8 has no adaptive icon, so it gets the mark on its ground
    // as a circle (what those launchers show).
    const Map<String, double> densities = <String, double>{
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };
    for (final MapEntry<String, double> density in densities.entries) {
      final Uint8List png = (await tester.runAsync(
        () => render(const _Rounded(KuberBrandMarkPainter.light), density.value),
      ))!;
      write('$res/mipmap-${density.key}/ic_launcher.png', png);
    }
  });

  testWidgets('draws the splash marks', (WidgetTester tester) async {
    // Android 12+ masks the splash icon to a 192dp circle on a 288dp canvas;
    // the board draws the glyph at 2x there (216 of 288 = 0.75). Glyph only,
    // the ground comes from `icon_background_color`.
    for (final (String name, KuberBrandMarkPainter p) in [
      ('splash_android12', KuberBrandMarkPainter.light),
      ('splash_android12_dark', KuberBrandMarkPainter.night),
    ]) {
      final Uint8List png = (await tester.runAsync(
        () => render(_Inset(p.glyphOnly, factor: 0.75), 1152),
      ))!;
      write('assets/icon/$name.png', png);
    }

    // The legacy splash draws the whole icon, ground and all, centred on the
    // page colour, so it reads as the launcher icon sitting still.
    for (final (String name, KuberBrandMarkPainter p) in [
      ('splash', KuberBrandMarkPainter.light),
      ('splash_dark', KuberBrandMarkPainter.night),
    ]) {
      final Uint8List png = (await tester.runAsync(
        () => render(_Rounded(p), 384),
      ))!;
      write('assets/icon/$name.png', png);
    }
  });
}

/// Draws [child] centred at [factor] of the box, on transparent.
class _Inset extends CustomPainter {
  const _Inset(this.child, {required this.factor});

  final CustomPainter child;
  final double factor;

  @override
  void paint(Canvas canvas, Size size) {
    final double inner = size.width * factor;
    final double edge = (size.width - inner) / 2;
    canvas
      ..save()
      ..translate(edge, edge);
    child.paint(canvas, Size(inner, inner));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Inset old) => true;
}

/// Draws [child] clipped to a circle, which is how a launcher shows it.
class _Rounded extends CustomPainter {
  const _Rounded(this.child);

  final CustomPainter child;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..clipPath(
        Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
    child.paint(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Rounded old) => true;
}
