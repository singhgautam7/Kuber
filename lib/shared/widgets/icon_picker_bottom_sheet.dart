import 'dart:io';

import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/icon_mapper.dart';
import 'app_icon_button.dart';
import 'kuber_bottom_sheet.dart';

/// Keys with this prefix render as a bundled monochrome bank SVG
/// (`assets/bank_icons/<name>.svg`), tinted like any other glyph. Used by the
/// Kuber Cards icon picker. Other pickers never pass such keys.
const String _bankPrefix = 'bank/';

/// A [onSelected] value with this prefix is a user-picked gallery image at an
/// absolute path.
const String _galleryPrefix = 'gallery:';

/// Set once the bundled bank SVGs have been decoded into `svg.cache` (the
/// XML->vector compile is the expensive step). Module-level so reopening the
/// picker skips the warm-up loader entirely; the cache itself lives for the
/// app's lifetime.
bool _bankIconsWarmed = false;

/// Warms `svg.cache` with the bank monograms in [bankKeys] so the grid decodes
/// them from memory instead of parsing SVG XML during the sheet's open
/// animation. `SvgLoader.loadBytes` populates the cache on first call and
/// returns the cached bytes thereafter, so this is cheap on repeat runs.
Future<void> _warmBankIcons(List<String> bankKeys) async {
  await Future.wait(
    bankKeys.map((key) async {
      final name = key.substring(_bankPrefix.length);
      try {
        await SvgAssetLoader('assets/bank_icons/$name.svg').loadBytes(null);
      } catch (_) {
        // A missing/broken asset must not block the picker; it falls back to a
        // neutral bank icon at render time.
      }
    }),
  );
}

Future<void> showIconPicker({
  required BuildContext context,
  required List<String> iconKeys,
  required Map<String, List<String>> tags,
  required String? selected,
  required ValueChanged<String> onSelected,
  Map<String, String>? bankLabels,
  bool allowGallery = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => KuberBottomSheet(
      title: 'Choose icon',
      child: IconPickerBody(
        iconKeys: iconKeys,
        tags: tags,
        selected: selected,
        onSelected: (key) {
          onSelected(key);
          Navigator.of(sheetContext, rootNavigator: true).pop();
        },
        bankLabels: bankLabels ?? const {},
        allowGallery: allowGallery,
      ),
    ),
  );
}

/// Search pill + lazily built icon grid. Reports a pick through [onSelected];
/// the host decides whether to close (single picker) or keep it open
/// (Icon / Colour sheet).
class IconPickerBody extends StatefulWidget {
  final List<String> iconKeys;
  final Map<String, List<String>> tags;
  final String? selected;
  final ValueChanged<String> onSelected;

  /// Optional display names for `bank/*` keys (so search + labels resolve).
  final Map<String, String> bankLabels;

  /// Adds a "From gallery" action that picks an image via `image_picker`.
  final bool allowGallery;

  const IconPickerBody({
    super.key,
    required this.iconKeys,
    required this.tags,
    required this.selected,
    required this.onSelected,
    this.bankLabels = const {},
    this.allowGallery = false,
  });

  @override
  State<IconPickerBody> createState() => _IconPickerBodyState();
}

class _IconPickerBodyState extends State<IconPickerBody> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  late List<String> _filtered = widget.iconKeys;

  /// False only while the bundled bank SVGs are warming on the very first open;
  /// the grid shows a brief loader until then. The sheet itself always opens.
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final bankKeys = widget.iconKeys
        .where((k) => k.startsWith(_bankPrefix))
        .toList();
    if (bankKeys.isEmpty || _bankIconsWarmed) {
      // No SVGs to warm (category/account pickers) or already warmed: render at
      // once, no loader.
      _ready = true;
    } else {
      _warmBankIcons(bankKeys).whenComplete(() {
        _bankIconsWarmed = true;
        if (mounted) setState(() => _ready = true);
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.iconKeys;
        return;
      }

      _filtered = widget.iconKeys.where((key) {
        if (key.toLowerCase().contains(q)) return true;
        if (_labelFor(key).toLowerCase().contains(q)) return true;
        return (widget.tags[key] ?? const <String>[]).any(
          (tag) => tag.toLowerCase().contains(q),
        );
      }).toList();
    });
  }

  String _labelFor(String key) =>
      widget.bankLabels[key] ?? IconMapper.labelFor(key);

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 256,
      maxHeight: 256,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    final dir = await getApplicationDocumentsDirectory();
    final iconsDir = Directory(p.join(dir.path, 'card_icons'));
    if (!iconsDir.existsSync()) iconsDir.createSync(recursive: true);
    final dest = p.join(
      iconsDir.path,
      'card_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}',
    );
    await File(picked.path).copy(dest);
    if (!mounted) return;
    widget.onSelected('$_galleryPrefix$dest');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Board 3.16: plain icon squares, 6 across; bank logos keep their
    // label (4 across) because the marks are hard to tell apart.
    final hasBanks = widget.iconKeys.any((k) => k.startsWith(_bankPrefix));
    final wide = MediaQuery.of(context).size.width >= 600;
    final columns = hasBanks ? (wide ? 5 : 4) : (wide ? 8 : 6);

    const pill = OutlineInputBorder(
      borderRadius: KuberShape.fullR,
      borderSide: BorderSide.none,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          autofocus: false,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onChanged: _onSearch,
          textAlignVertical: TextAlignVertical.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: cs.onSurface),
          decoration: InputDecoration(
            hintText: 'Search icons',
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
            prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? AppIconButton(
                    icon: Icons.close_rounded,
                    kind: AppIconButtonKind.plain,
                    semanticLabel: 'Clear search',
                    onPressed: () {
                      _searchCtrl.clear();
                      _onSearch('');
                    },
                  )
                : null,
            filled: true,
            fillColor: cs.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: pill,
            enabledBorder: pill,
            focusedBorder: OutlineInputBorder(
              borderRadius: KuberShape.fullR,
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: KuberSpace.md),
        // A bounded, LAZILY-built scroll area: only the icon cells actually on
        // screen are constructed. Previously the grid was `shrinkWrap: true`
        // inside the sheet's own scroll view, which forced EVERY cell to build
        // at once on open and on each keystroke. For the Kuber Cards picker
        // that meant ~200 cells including ~40 bundled bank SVGs (each parsed +
        // rasterized by flutter_svg) — the source of the jitter. The category
        // picker never felt it: fewer cells and only cheap font glyphs. Making
        // the grid a real viewport (SliverGrid) builds ~a dozen cells at a
        // time regardless of how many icons or SVGs are in the list. The
        // gallery row rides inside the same scroll so it is not pinned.
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.52,
          child: !_ready
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
              ? _IconPickerEmpty(query: _searchCtrl.text)
              : CustomScrollView(
                  slivers: [
                    if (widget.allowGallery && _searchCtrl.text.isEmpty) ...[
                      SliverToBoxAdapter(
                        child: _GalleryPickRow(onTap: _pickFromGallery),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: KuberSpace.md),
                      ),
                    ],
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: KuberSpace.sm,
                        crossAxisSpacing: KuberSpace.sm,
                        childAspectRatio: 0.95,
                      ),
                      delegate: SliverChildBuilderDelegate((_, index) {
                        final key = _filtered[index];
                        return _IconCell(
                          iconKey: key,
                          label: _labelFor(key),
                          isSelected: key == widget.selected,
                          onTap: () => widget.onSelected(key),
                        );
                      }, childCount: _filtered.length),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// "From gallery" action row shown at the top of the picker when
/// `allowGallery` is set (Kuber Cards).
class _GalleryPickRow extends StatelessWidget {
  final VoidCallback onTap;
  const _GalleryPickRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberShape.medium),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 20,
                color: cs.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'From gallery',
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCell extends StatelessWidget {
  final String iconKey;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconCell({
    required this.iconKey,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isBank = iconKey.startsWith(_bankPrefix);
    final fg = isSelected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    final glyph = isBank
        ? SvgPicture.asset(
            'assets/bank_icons/${iconKey.substring(_bankPrefix.length)}.svg',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
            placeholderBuilder: (_) =>
                Icon(Icons.account_balance_rounded, size: 22, color: fg),
          )
        : Icon(IconMapper.fromString(iconKey), size: 22, color: fg);
    // Outlined r12 square; selected = secondaryContainer + 2dp primary.
    return Tooltip(
      message: label,
      triggerMode: TooltipTriggerMode.longPress,
      child: Material(
        color: isSelected ? cs.secondaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: KuberShape.mediumR,
          side: BorderSide(
            color: isSelected ? cs.primary : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: isBank
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      glyph,
                      const SizedBox(height: 4),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall!
                            .copyWith(color: fg, letterSpacing: 0),
                      ),
                    ],
                  ),
                )
              : Center(child: glyph),
        ),
      ),
    );
  }
}

class _IconPickerEmpty extends StatelessWidget {
  final String query;

  const _IconPickerEmpty({required this.query});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 32,
            color: cs.onSurfaceVariant.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'No icons match ',
                  style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
                ),
                TextSpan(
                  text: '"$query"',
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different word, or clear the search.',
            style: localeFont(
              fontSize: 12,
              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
