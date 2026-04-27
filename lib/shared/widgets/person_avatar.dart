import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum PersonAvatarSize { small, medium, large }

// Eight muted accent colours for avatar backgrounds — deterministic by name hash.
// These are intentional fixed values (not theme roles) since they serve as
// distinguishing hues across different people.
const _kAvatarColors = [
  Color(0xFF3B5BDB), // indigo
  Color(0xFF2F9E44), // green
  Color(0xFFE8590C), // orange
  Color(0xFF862E9C), // purple
  Color(0xFF1098AD), // teal
  Color(0xFFD6336C), // pink
  Color(0xFF0C8599), // cyan
  Color(0xFF5C7CFA), // blue
];

class PersonAvatar extends StatelessWidget {
  final String name;
  final PersonAvatarSize size;

  const PersonAvatar({
    super.key,
    required this.name,
    this.size = PersonAvatarSize.medium,
  });

  double get _dimension => switch (size) {
    PersonAvatarSize.small => 28,
    PersonAvatarSize.medium => 36,
    PersonAvatarSize.large => 48,
  };

  double get _fontSize => switch (size) {
    PersonAvatarSize.small => 10,
    PersonAvatarSize.medium => 13,
    PersonAvatarSize.large => 18,
  };

  Color get _bgColor {
    final hash = name.codeUnits.fold(0, (h, c) => h + c);
    return _kAvatarColors[hash % _kAvatarColors.length];
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
    final dim = _dimension;
    return Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        color: _bgColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
