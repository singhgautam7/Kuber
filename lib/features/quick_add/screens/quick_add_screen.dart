import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/models/info_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/services/shortcut_pin_service.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../services/quick_add_confirm.dart';
import '../services/quick_add_parser.dart';
import '../services/quick_add_resolver.dart';
import '../services/quick_add_voice_controller.dart';
import '../widgets/quick_add_voice_overlay.dart';
import '../widgets/transaction_preview_card.dart';

/// Full-screen Quick Add page. Type or speak to log one or many transactions;
/// nothing is written until the user confirms. Opened from the home Quick Add
/// widget's "Full screen" button and the More tab tile.
class QuickAddScreen extends ConsumerStatefulWidget {
  /// When true (opened from the home widget's mic), listening starts on load.
  final bool autoStartVoice;

  const QuickAddScreen({super.key, this.autoStartVoice = false});

  @override
  ConsumerState<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends ConsumerState<QuickAddScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _voice = QuickAddVoiceController();

  List<QuickAddDraft> _drafts = const [];
  bool _confirming = false;
  MicPermission _micPermission = MicPermission.granted;

  /// Field contents captured when voice starts, restored if the user cancels.
  String _preVoiceText = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_recompute);
    if (widget.autoStartVoice) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startVoice();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_recompute);
    _controller.dispose();
    _focusNode.dispose();
    _voice.dispose();
    super.dispose();
  }

  void _recompute() {
    final categories = ref.read(categoryListProvider).valueOrNull ?? const [];
    final accounts = ref.read(accountListProvider).valueOrNull ?? const [];
    final defaultId =
        ref.read(settingsProvider).valueOrNull?.defaultAccountId;
    final parsed = parseQuickAddMulti(_controller.text);
    setState(() {
      _drafts = resolveDrafts(
        parsed,
        categories: categories,
        accounts: accounts,
        defaultAccountId: defaultId,
      );
    });
  }

  // ── Voice ────────────────────────────────────────────────────────────────

  void _restorePreVoiceText() {
    _controller.value = TextEditingValue(
      text: _preVoiceText,
      selection: TextSelection.collapsed(offset: _preVoiceText.length),
    );
  }

  Future<void> _startVoice() async {
    var perm = await _voice.checkPermission();
    if (perm == MicPermission.denied) perm = await _voice.requestPermission();
    if (!mounted) return;
    setState(() => _micPermission = perm);
    if (perm != MicPermission.granted) {
      if (perm == MicPermission.permanentlyDenied) _showMicDeniedDialog();
      return;
    }
    _focusNode.unfocus();
    _preVoiceText = _controller.text;
    await _voice.start(onTranscript: (text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  void _showMicDeniedDialog() {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        title: Text('Microphone access off',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
        content: Text(
          'Voice input needs the microphone. Turn it on in system settings, or type your transaction instead.',
          style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Not now',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ),
          AppButton(
            label: 'Open settings',
            type: AppButtonType.primary,
            width: 150,
            height: 44,
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
          ),
        ],
      ),
    );
  }

  // ── Edit / resolve individual cards ──────────────────────────────────────

  void _editCategory(int index) {
    final draft = _drafts[index];
    final cs = Theme.of(context).colorScheme;
    _focusNode.unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: draft.categoryId,
        defaultType: draft.type,
        onSelected: (id) {
          Navigator.pop(context);
          _applyCategory(index, id);
        },
      ),
    );
  }

  void _applyCategory(int index, int categoryId) {
    final categories = ref.read(categoryListProvider).valueOrNull ?? const [];
    final cat = categories.firstWhereOrNull((c) => c.id == categoryId);
    if (cat == null || index >= _drafts.length) return;
    final d = _drafts[index];
    final status = d.accountId == null
        ? QuickAddDraftStatus.missingAccount
        : QuickAddDraftStatus.ready;
    setState(() {
      _drafts = [..._drafts]..[index] = d.copyWith(
          status: status,
          categoryId: cat.id,
          categoryName: cat.name,
          categoryIcon: cat.icon,
          categoryColor: cat.colorValue,
        );
    });
  }

  Future<void> _setDefaultAccount() async {
    _focusNode.unfocus();
    await context.push('/more/settings');
    if (mounted) _recompute();
  }

  // ── Confirm ──────────────────────────────────────────────────────────────

  int get _readyCount => _drafts.where((d) => d.counts).length;
  bool get _hasBlocker =>
      _drafts.any((d) => d.status == QuickAddDraftStatus.missingAccount);
  bool get _canConfirm => _readyCount >= 1 && !_hasBlocker && !_confirming;

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    setState(() => _confirming = true);
    // New categories (if any) are created here, at confirm time, deduped.
    final txns = await materializeDrafts(ref, _drafts, source: 'quick_add');
    if (txns.isEmpty) {
      if (mounted) setState(() => _confirming = false);
      return;
    }
    await ref.read(transactionListProvider.notifier).addMany(txns);
    if (!mounted) return;
    final n = txns.length;
    // Snackbar uses the root overlay, so it survives the page pop.
    showKuberSnackBar(context, 'Added $n transaction${n == 1 ? '' : 's'}');
    context.pop();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasInput = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: cs.surface,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Column(
            children: [
              KuberAppBar(
                showBack: true,
                showBrand: false,
                pinShortcut: const PinShortcutSpec(
                  shortcutId: 'quick_add',
                  shortLabel: 'Quick Add',
                  longLabel: 'Quick Add',
                  iconDrawable: 'ic_shortcut_quickadd',
                  deepLink: 'kuber://app/quick-add',
                ),
                infoConfig: _infoConfig(),
              ),
              Expanded(
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(
                      child: KuberPageHeader(
                        title: 'Quick Add',
                        description: 'Type or speak to log transactions',
                        onAction: null,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                          KuberSpacing.lg, 0, KuberSpacing.lg, KuberSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _inputSurface(cs),
                          const SizedBox(height: KuberSpacing.md),
                          _voicePill(cs),
                          const SizedBox(height: KuberSpacing.lg),
                          if (hasInput)
                            _previewSection(cs)
                          else
                            _referenceBlock(cs),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              _actionBar(cs),
            ],
          ),
          QuickAddVoiceOverlay(
            controller: _voice,
            // Okay: finalize and keep the recognized text.
            onStop: () => _voice.stop(),
            // Cancel: abort and restore whatever was in the field before.
            onCancel: () {
              _voice.cancel();
              _restorePreVoiceText();
            },
            onTypeInstead: () {
              _voice.cancel();
              _restorePreVoiceText();
              _focusNode.requestFocus();
            },
            onRetry: _startVoice,
          ),
        ],
      ),
    );
  }

  Widget _inputSurface(ColorScheme cs) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      minLines: 3,
      maxLines: 6,
      style: TextStyle(fontSize: 15, height: 1.5, color: cs.onSurface),
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: '250 in groceries\n250 groceries and 300 movies\n1200 salary income',
        hintStyle: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: cs.onSurfaceVariant.withValues(alpha: 0.55),
        ),
        filled: true,
        fillColor: cs.surfaceContainerHigh,
        contentPadding: const EdgeInsets.all(KuberSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.lg),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.lg),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.lg),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
      ),
    );
  }

  Widget _voicePill(ColorScheme cs) {
    final denied = _micPermission == MicPermission.permanentlyDenied;
    return GestureDetector(
      onTap: denied ? openAppSettings : _startVoice,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: denied
              ? cs.surfaceContainerHigh
              : cs.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: denied
                ? cs.outline
                : cs.primary.withValues(alpha: 0.40),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              denied ? Icons.mic_off_rounded : Icons.mic_rounded,
              size: 18,
              color: denied ? cs.onSurfaceVariant : cs.primary,
            ),
            const SizedBox(width: KuberSpacing.sm),
            Text(
              denied ? 'Mic access off' : 'Tap to speak',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: denied ? cs.onSurfaceVariant : cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewSection(ColorScheme cs) {
    final total = _drafts.length;
    final parsedCount = _drafts.where((d) => d.amount != null).length;
    final skipped = total - parsedCount;
    final label = parsedCount <= 1
        ? '$parsedCount TRANSACTION'
        : '$parsedCount TRANSACTIONS DETECTED';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            Expanded(child: Divider(color: cs.outline.withValues(alpha: 0.4))),
          ],
        ),
        const SizedBox(height: KuberSpacing.md),
        for (var i = 0; i < _drafts.length; i++) ...[
          if (i > 0) const SizedBox(height: 9),
          TransactionPreviewCard(
            draft: _drafts[i],
            onEdit: _drafts[i].amount != null ? () => _editCategory(i) : null,
            onPickCategory: () => _editCategory(i),
            onSetDefaultAccount: _setDefaultAccount,
          ),
        ],
        if (skipped > 0) ...[
          const SizedBox(height: KuberSpacing.sm),
          Text(
            '$skipped line${skipped == 1 ? '' : 's'} skipped',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  Widget _referenceBlock(ColorScheme cs) {
    Widget row(String text, String hint, {bool income = false}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: KuberSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: income ? cs.tertiary : cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(hint, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT YOU CAN TYPE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
        row('250 in groceries', 'Amount and category'),
        row('250 groceries and 300 movies', 'Two at once, split with "and"'),
        row('1200 salary income', 'Income, tinted green', income: true),
      ],
    );
  }

  Widget _actionBar(ColorScheme cs) {
    // Solid pinned footer, matching the Add Transaction save bar (opaque
    // surface + top border), so nothing shows through behind the buttons.
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      padding: EdgeInsets.fromLTRB(
        KuberSpacing.lg,
        KuberSpacing.md,
        KuberSpacing.lg,
        MediaQuery.of(context).viewPadding.bottom + KuberSpacing.md,
      ),
      child: Row(
        children: [
          AppButton(
            label: 'Cancel',
            type: AppButtonType.outline,
            width: 100,
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: AppButton(
              label: _confirmLabel(),
              type: AppButtonType.primary,
              fullWidth: true,
              isLoading: _confirming,
              onPressed: _canConfirm ? _confirm : null,
            ),
          ),
        ],
      ),
    );
  }

  String _confirmLabel() {
    final n = _readyCount;
    if (n == 0) return 'Nothing to add yet';
    if (n == 1) return 'Add 1 transaction';
    return 'Add $n transactions';
  }

  KuberInfoConfig _infoConfig() {
    return const KuberInfoConfig(
      title: 'Quick Add',
      description: 'Type or speak to log one or many transactions in one pass.',
      items: [
        KuberInfoItem(
          icon: Icons.flash_on_rounded,
          title: 'Amount first',
          description: 'Start with the amount, e.g. "250 groceries".',
        ),
        KuberInfoItem(
          icon: Icons.add_rounded,
          title: 'Many at once',
          description: 'Split lines with "and", a comma, "+" or "&".',
        ),
        KuberInfoItem(
          icon: Icons.trending_up_rounded,
          title: 'Income',
          description: 'Words like "salary" or "received" log it as income.',
        ),
        KuberInfoItem(
          icon: Icons.mic_rounded,
          title: 'Speak it',
          description: 'Tap the mic. Recognition runs on your device.',
        ),
        KuberInfoItem(
          icon: Icons.check_circle_outline_rounded,
          title: 'Always confirm',
          description: 'Nothing is saved until you tap Add.',
        ),
      ],
    );
  }
}
