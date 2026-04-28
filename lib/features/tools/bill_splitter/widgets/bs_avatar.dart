import 'package:flutter/material.dart';

import 'bs_squircle_shape.dart';

/// The 8-entry deterministic avatar palette from the design spec.
/// Index is determined by: name.codeUnits.sum % 8
const _kBsPalette = [
  _BsPaletteEntry(bg: Color(0x2E3B82F6), fg: Color(0xFF60A5FA)), // blue
  _BsPaletteEntry(bg: Color(0x2E22C55E), fg: Color(0xFF4ADE80)), // green
  _BsPaletteEntry(bg: Color(0x33F59E0B), fg: Color(0xFFFBBF24)), // amber
  _BsPaletteEntry(bg: Color(0x2EA855F7), fg: Color(0xFFC084FC)), // purple
  _BsPaletteEntry(bg: Color(0x2EEC4899), fg: Color(0xFFF472B6)), // pink
  _BsPaletteEntry(bg: Color(0x3314B8A6), fg: Color(0xFF5EEAD4)), // teal
  _BsPaletteEntry(bg: Color(0x2EF472B6), fg: Color(0xFFFB7185)), // rose
  _BsPaletteEntry(bg: Color(0x3384CC16), fg: Color(0xFFA3E635)), // lime
];

/// "You" always uses primary blue palette.
const _kYouPalette = _BsPaletteEntry(
  bg: Color(0x1A3B82F6),
  fg: Color(0xFF3B82F6),
);

class _BsPaletteEntry {
  final Color bg;
  final Color fg;
  const _BsPaletteEntry({required this.bg, required this.fg});
}

/// A squircle avatar for the Bill Splitter feature.
/// Uses [ContinuousRectangleBorder] (Flutter built-in) for smooth corners.
/// "You" always uses primary blue. Other names use a deterministic palette.
class BsAvatar extends StatelessWidget {
  final String name;
  final double size;

  const BsAvatar({super.key, required this.name, this.size = 40});

  bool get _isYou => name == 'You';

  _BsPaletteEntry get _palette {
    if (_isYou) return _kYouPalette;
    final hash = name.codeUnits.fold(0, (h, c) => h + c);
    return _kBsPalette[hash % _kBsPalette.length];
  }

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length == 1) return words[0][0].toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final r = size * 0.35;

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: palette.bg,
        shape: bsSquircle(r),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          color: palette.fg,
          height: 1,
        ),
      ),
    );
  }
}

/// A squircle icon tile (e.g. receipt icon in bill rows).
class BsIconTile extends StatelessWidget {
  final IconData icon;
  final double size;
  final double cornerRadius;

  const BsIconTile({
    super.key,
    required this.icon,
    this.size = 42,
    this.cornerRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: cs.surfaceContainerHigh,
        shape: bsSquircle(cornerRadius, side: BorderSide(color: cs.outline)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: cs.primary, size: size * 0.43),
    );
  }
}

/// A squircle close/action button (sheet headers).
class BsSquircleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;

  const BsSquircleButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(
          color: cs.surfaceContainerHigh,
          shape: bsSquircle(10, side: BorderSide(color: cs.outline)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: cs.onSurfaceVariant, size: size * 0.44),
      ),
    );
  }
}

/// Section label row (title left, optional trailing widget right).
class BsSectionLabel extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const BsSectionLabel({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: cs.onSurfaceVariant,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
