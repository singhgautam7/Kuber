import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/utils/icon_mapper.dart';
import '../data/bank_icons.dart';

/// Prefix marking a user-picked gallery image stored at an absolute path.
const kGalleryIconPrefix = 'gallery:';

/// Prefix marking a bundled monochrome bank SVG (asset `assets/bank_icons/<name>.svg`).
const kBankIconPrefix = 'bank/';

bool _bankCacheWarmed = false;

/// Decodes the bundled bank monogram SVGs into flutter_svg's cache so the first
/// cards-home render (and the icon picker) draws them warm, instead of decoding
/// ~25 vectors on the main isolate mid-frame while the unlock screen paints.
/// Idempotent and cheap to call on every Kuber Cards home open. Deliberately
/// lazy — never invoked at app boot.
Future<void> warmBankIconCache() async {
  if (_bankCacheWarmed) return;
  _bankCacheWarmed = true;
  await Future.wait(kBankIconKeys.map((key) async {
    final name = key.substring(kBankIconPrefix.length);
    try {
      await SvgAssetLoader('assets/bank_icons/$name.svg').loadBytes(null);
    } catch (_) {
      // A missing/broken asset just falls back to the neutral glyph at render.
    }
  }));
}

/// Resolves a Kuber Cards icon key to a rendered, tinted glyph. Handles three
/// sources uniformly (see `specs/plans/kuber-cards.md` §5.1):
///  - `gallery:<abs-path>` -> the user's image (not tinted),
///  - `bank/<name>`        -> a bundled monochrome SVG, tinted [color],
///  - any other key        -> an `IconMapper` Material glyph, tinted [color].
class CardIcon extends StatelessWidget {
  final String? iconKey;
  final double size;
  final Color color;

  const CardIcon({
    super.key,
    required this.iconKey,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final key = iconKey;

    if (key != null && key.startsWith(kGalleryIconPrefix)) {
      final path = key.substring(kGalleryIconPrefix.length);
      // No synchronous `existsSync()` here: that would be a blocking filesystem
      // stat on every list-row build/scroll. `Image.file` decodes via Flutter's
      // path-keyed image cache and its errorBuilder covers a missing file.
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(path),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }

    if (key != null && key.startsWith(kBankIconPrefix)) {
      final name = key.substring(kBankIconPrefix.length);
      return SvgPicture.asset(
        'assets/bank_icons/$name.svg',
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (_) => _fallback(),
      );
    }

    return Icon(
      key != null ? IconMapper.fromString(key) : Icons.credit_card_rounded,
      size: size,
      color: color,
    );
  }

  Widget _fallback() =>
      Icon(Icons.credit_card_rounded, size: size, color: color);
}
