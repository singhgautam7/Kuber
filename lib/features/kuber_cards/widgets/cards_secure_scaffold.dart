import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/card_secure_screen.dart';
import '../providers/kuber_cards_provider.dart';
import '../screens/cards_unlock_screen.dart';

/// Wraps every Kuber Cards screen with two guarantees:
///  1. FLAG_SECURE is on while any cards screen is visible (ref-counted via
///     [CardSecureScreen]).
///  2. When [requiresUnlock] is true and the vault is locked, an opaque unlock
///     overlay covers the child (so card content never shows without a fresh
///     unlock). Form state underneath is preserved because the child stays in
///     the tree.
///
/// The 60s auto-lock is handled centrally by the app lifecycle observer in
/// `app.dart` (this widget deliberately does NOT register its own
/// WidgetsBindingObserver, which interfered with back navigation). See
/// `specs/plans/kuber-cards.md` §3, §8.
class CardsSecureScaffold extends ConsumerStatefulWidget {
  final Widget child;

  /// Setup and the unlock screen itself pass false (nothing to gate behind an
  /// unlock); home / add / edit / settings pass true.
  final bool requiresUnlock;

  const CardsSecureScaffold({
    super.key,
    required this.child,
    this.requiresUnlock = true,
  });

  @override
  ConsumerState<CardsSecureScaffold> createState() =>
      _CardsSecureScaffoldState();
}

class _CardsSecureScaffoldState extends ConsumerState<CardsSecureScaffold> {
  @override
  void initState() {
    super.initState();
    CardSecureScreen.acquire();
  }

  @override
  void dispose() {
    CardSecureScreen.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = widget.requiresUnlock && !ref.watch(cardsUnlockedProvider);
    return Stack(
      children: [
        widget.child,
        if (locked) const Positioned.fill(child: CardsUnlockScreen()),
      ],
    );
  }
}
