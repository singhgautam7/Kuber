import 'dart:math';

class AppColorPalette {
  static const int kVibrantBlue = 0xFF3B82F6;
  static const int kVibrantIndigo = 0xFF6366F1;
  static const int kVibrantViolet = 0xFF8B5CF6;
  static const int kVibrantPink = 0xFFEC4899;
  static const int kVibrantRose = 0xFFF43F5E;
  static const int kVibrantRed = 0xFFEF4444;
  static const int kVibrantOrange = 0xFFF97316;
  static const int kVibrantAmber = 0xFFF59E0B;
  static const int kVibrantYellow = 0xFFEAB308;
  static const int kVibrantLime = 0xFF84CC16;
  static const int kVibrantGreen = 0xFF22C55E;
  static const int kVibrantEmerald = 0xFF10B981;
  static const int kVibrantTeal = 0xFF14B8A6;
  static const int kVibrantCyan = 0xFF06B6D4;
  static const int kVibrantSky = 0xFF0EA5E9;
  static const int kVibrantPurple = 0xFFA855F7;
  static const int kVibrantFuchsia = 0xFFD946EF;
  static const int kVibrantCoral = 0xFFFB7185;

  static const List<int> kVibrant = <int>[
    kVibrantBlue,
    kVibrantIndigo,
    kVibrantViolet,
    kVibrantPink,
    kVibrantRose,
    kVibrantRed,
    kVibrantOrange,
    kVibrantAmber,
    kVibrantYellow,
    kVibrantLime,
    kVibrantGreen,
    kVibrantEmerald,
    kVibrantTeal,
    kVibrantCyan,
    kVibrantSky,
    kVibrantPurple,
    kVibrantFuchsia,
    kVibrantCoral,
  ];

  static const int kMutedBlue = 0xFF64748B;
  static const int kMutedTeal = 0xFF5EAD9D;
  static const int kMutedGreen = 0xFF7C9E78;
  static const int kMutedAmber = 0xFFB89B6E;
  static const int kMutedRose = 0xFFB8748B;
  static const int kMutedViolet = 0xFF8C7CB0;
  static const int kMutedSlate = 0xFF7B8294;
  static const int kMutedSand = 0xFFA89F8B;

  static const List<int> kMuted = <int>[
    kMutedBlue,
    kMutedTeal,
    kMutedGreen,
    kMutedAmber,
    kMutedRose,
    kMutedViolet,
    kMutedSlate,
    kMutedSand,
  ];

  static const int kNeutralBlack = 0xFF27272A;
  static const int kNeutralDark = 0xFF52525B;
  static const int kNeutralMid = 0xFF71717A;
  static const int kNeutralLight = 0xFFA1A1AA;
  static const int kNeutralPale = 0xFFD4D4D8;
  static const int kNeutralStone = 0xFF78716C;

  static const List<int> kNeutral = <int>[
    kNeutralBlack,
    kNeutralDark,
    kNeutralMid,
    kNeutralLight,
    kNeutralPale,
    kNeutralStone,
  ];

  static const List<int> kAll = <int>[...kVibrant, ...kMuted, ...kNeutral];

  static const List<int> colors = <int>[
    kVibrantBlue,
    kVibrantIndigo,
    kVibrantViolet,
    kVibrantPink,
    kVibrantRed,
    kVibrantOrange,
    kVibrantAmber,
    kVibrantEmerald,
    kVibrantTeal,
    kVibrantCyan,
    kMutedBlue,
    kNeutralStone,
  ];

  static String nameFor(int value) => _names[value] ?? 'Color';

  static const Map<int, String> _names = <int, String>{
    kVibrantBlue: 'Blue',
    kVibrantIndigo: 'Indigo',
    kVibrantViolet: 'Violet',
    kVibrantPink: 'Pink',
    kVibrantRose: 'Rose',
    kVibrantRed: 'Red',
    kVibrantOrange: 'Orange',
    kVibrantAmber: 'Amber',
    kVibrantYellow: 'Yellow',
    kVibrantLime: 'Lime',
    kVibrantGreen: 'Green',
    kVibrantEmerald: 'Emerald',
    kVibrantTeal: 'Teal',
    kVibrantCyan: 'Cyan',
    kVibrantSky: 'Sky',
    kVibrantPurple: 'Purple',
    kVibrantFuchsia: 'Fuchsia',
    kVibrantCoral: 'Coral',
    kMutedBlue: 'Slate blue',
    kMutedTeal: 'Sage teal',
    kMutedGreen: 'Sage',
    kMutedAmber: 'Tan',
    kMutedRose: 'Dusty rose',
    kMutedViolet: 'Lavender',
    kMutedSlate: 'Slate',
    kMutedSand: 'Sand',
    kNeutralBlack: 'Charcoal',
    kNeutralDark: 'Graphite',
    kNeutralMid: 'Stone',
    kNeutralLight: 'Mist',
    kNeutralPale: 'Linen',
    kNeutralStone: 'Bark',
  };

  static int getRandomColor() {
    return kVibrant[Random().nextInt(kVibrant.length)];
  }
}
