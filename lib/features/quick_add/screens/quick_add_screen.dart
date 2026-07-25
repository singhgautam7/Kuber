import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/info_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/utils/category_fuzzy_matcher.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/transaction_preview_card.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../dashboard/utils/quick_add_parser.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/widgets/account_picker_sheet.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../widgets/voice_overlay.dart';

class QuickAddScreen extends ConsumerStatefulWidget {
  final String? initialText;
  final bool openVoiceImmediately;

  const QuickAddScreen({
    super.key,
    this.initialText,
    this.openVoiceImmediately = false,
  });

  @override
  ConsumerState<QuickAddScreen> createState() => _QuickAddScreenState();
}

class _QuickAddScreenState extends ConsumerState<QuickAddScreen> {
  final _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  List<QuickAddParsedItem> _parsedItems = [];
  int? _editingIndex;
  bool _showVoiceOverlay = false;
  String _sourceType = 'quick_add'; // 'quick_add' | 'voice'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _inputController.text = widget.initialText!;
    }
    _showVoiceOverlay = widget.openVoiceImmediately;
    _inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final text = _inputController.text;
    final categories = ref.read(categoryListProvider).valueOrNull ?? [];
    setState(() {
      if (text.trim().isEmpty) {
        _parsedItems = [];
        _editingIndex = null;
      } else {
        _parsedItems = parseMultiQuickAdd(text, categories);
      }
    });
  }

  Future<void> _handleSave() async {
    if (_parsedItems.isEmpty || _isSubmitting) return;

    final accounts = ref.read(accountListProvider).valueOrNull ?? [];
    final categories = ref.read(categoryListProvider).valueOrNull ?? [];
    final settings = await ref.read(settingsProvider.future);
    final defaultAccId = settings.defaultAccountId;

    // Verify all items have valid amounts and accounts
    for (final item in _parsedItems) {
      if (item.amount == null || item.amount! <= 0) return;
      String? accId;
      if (item.accountHint != null) {
        accId = accounts
            .where((a) => a.name.toLowerCase().contains(item.accountHint!.toLowerCase()))
            .firstOrNull
            ?.id
            .toString();
      }
      accId ??= defaultAccId;
      if (accId == null) return;
    }

    setState(() => _isSubmitting = true);

    int addedCount = 0;
    for (final item in _parsedItems) {
      String? resolvedAccId;
      if (item.accountHint != null) {
        resolvedAccId = accounts
            .where((a) => a.name.toLowerCase().contains(item.accountHint!.toLowerCase()))
            .firstOrNull
            ?.id
            .toString();
      }
      resolvedAccId ??= defaultAccId;

      Category? cat = item.matchResult.category;
      cat ??= categories.where((c) => c.name.toLowerCase() == 'general' || c.name.toLowerCase() == 'other').firstOrNull;
      cat ??= categories.firstOrNull;

      if (cat == null || resolvedAccId == null) continue;

      final name = item.categoryCandidate?.isNotEmpty == true
          ? item.categoryCandidate!
          : cat.name;

      final txn = Transaction()
        ..name = name
        ..nameLower = name.toLowerCase()
        ..amount = item.amount!
        ..type = item.type
        ..categoryId = cat.id.toString()
        ..accountId = resolvedAccId
        ..quickAddNote = _inputController.text
        ..importSource = _sourceType
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await ref.read(transactionListProvider.notifier).add(txn);
      addedCount++;
    }

    if (!mounted) return;
    showKuberSnackBar(
      context,
      addedCount == 1 ? 'Transaction added' : '$addedCount transactions added',
    );
    context.pop();
  }

  void _showHelpInfo() {
    KuberInfoBottomSheet.show(
      context,
      KuberInfoConfig(
        title: 'Quick Add Guide',
        description: 'Type or speak to add one or multiple transactions instantly.',
        items: const [
          KuberInfoItem(
            icon: Icons.flash_on_rounded,
            title: 'Basic Amount & Category',
            description: 'Type "250 groceries" or "300 movies".',
          ),
          KuberInfoItem(
            icon: Icons.splitscreen_rounded,
            title: 'Multiple Transactions',
            description: 'Separate with "and", newlines, or commas: "250 groceries and 400 rent".',
          ),
          KuberInfoItem(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Specify Account',
            description: 'Add "from HDFC" or "from Cash" to specify account.',
          ),
          KuberInfoItem(
            icon: Icons.mic_none_rounded,
            title: 'Voice Input',
            description: 'Tap the mic icon to speak transactions naturally in your voice.',
          ),
        ],
      ),
    );
  }

  void _openCategoryPicker(int index) {
    final categories = ref.read(categoryListProvider).valueOrNull ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: _parsedItems[index].matchResult.category?.id,
        onSelected: (catId) {
          final cat = categories.firstWhereOrNull((c) => c.id == catId);
          if (cat != null) {
            setState(() {
              _parsedItems[index] = _parsedItems[index].copyWith(
                matchResult: CategoryMatchResult.exact(cat, cat.name),
                categoryCandidate: cat.name,
              );
            });
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  void _openAccountPicker(int index) {
    final accounts = ref.read(accountListProvider).valueOrNull ?? [];
    int? currentAccId;
    if (_parsedItems[index].accountHint != null) {
      currentAccId = accounts
          .where((a) => a.name.toLowerCase().contains(_parsedItems[index].accountHint!.toLowerCase()))
          .firstOrNull
          ?.id;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AccountPickerSheet(
        selectedAccountId: currentAccId,
        onSelected: (accId) {
          final acc = accounts.where((a) => a.id == accId).firstOrNull;
          if (acc != null) {
            setState(() {
              _parsedItems[index] = _parsedItems[index].copyWith(accountHint: acc.name);
            });
          }
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _handleCreateNewCategory(int index) async {
    final candidate = _parsedItems[index].categoryCandidate;
    if (candidate == null || candidate.trim().isEmpty) return;

    final newCat = Category()
      ..name = candidate.trim()
      ..icon = 'circle'
      ..colorValue = 0xFF3B82F6
      ..type = 'expense';

    await ref.read(categoryListProvider.notifier).add(newCat);
    final categories = await ref.read(categoryListProvider.future);
    final created = categories.where((c) => c.name.toLowerCase() == candidate.trim().toLowerCase()).firstOrNull;

    if (created != null) {
      setState(() {
        _parsedItems[index] = _parsedItems[index].copyWith(
          matchResult: CategoryMatchResult.exact(created, created.name),
          categoryCandidate: created.name,
        );
      });
      if (mounted) showKuberSnackBar(context, 'Created category "${created.name}"');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accounts = ref.watch(accountListProvider).valueOrNull ?? [];
    final settings = ref.watch(settingsProvider).valueOrNull;
    final defaultAccId = settings?.defaultAccountId;
    final hasDefaultAcc = defaultAccId != null && accounts.any((a) => a.id.toString() == defaultAccId);

    // Check if any parsed item lacks a default account
    final bool missingAccountError = _parsedItems.isNotEmpty &&
        _parsedItems.any((item) {
          if (item.accountHint != null) {
            return !accounts.any((a) => a.name.toLowerCase().contains(item.accountHint!.toLowerCase()));
          }
          return !hasDefaultAcc;
        });

    final bool canSubmit = _parsedItems.isNotEmpty &&
        !missingAccountError &&
        _parsedItems.every((i) => i.amount != null && i.amount! > 0);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: cs.surface,
          appBar: KuberAppBar(
            showBack: true,
            showBrand: false,
            actions: [
              IconButton(
                icon: Icon(Icons.help_outline_rounded, color: cs.onSurfaceVariant),
                onPressed: _showHelpInfo,
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const KuberPageHeader(
                        title: 'Quick Add',
                        description: 'Type or speak. One line per expense.',
                      ),
                      const SizedBox(height: KuberSpacing.md),

                      // Input Box Container
                      Container(
                        constraints: const BoxConstraints(minHeight: 120),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainer,
                          borderRadius: BorderRadius.circular(KuberRadius.lg),
                          border: Border.all(
                            color: _inputFocusNode.hasFocus ? cs.primary : cs.outline,
                            width: _inputFocusNode.hasFocus ? 2.0 : 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.all(KuberSpacing.md),
                        child: Stack(
                          children: [
                            TextField(
                              controller: _inputController,
                              focusNode: _inputFocusNode,
                              maxLines: null,
                              minLines: 3,
                              style: localeFont(fontSize: 15, color: cs.onSurface),
                              decoration: InputDecoration(
                                hintText: '250 in groceries\n300 movies and 500 dinner',
                                hintStyle: localeFont(
                                  fontSize: 15,
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.55),
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.only(bottom: 40),
                              ),
                            ),
                            // Floating mic button
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () => setState(() => _showVoiceOverlay = true),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: cs.surfaceContainerHigh,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cs.outline),
                                  ),
                                  child: Icon(
                                    Icons.mic_none_rounded,
                                    size: 20,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: KuberSpacing.lg),

                      // Live Parsed List or Empty State
                      if (_parsedItems.isNotEmpty) ...[
                        Row(
                          children: [
                            Text(
                              '${_parsedItems.length} TRANSACTION${_parsedItems.length == 1 ? '' : 'S'} DETECTED',
                              style: localeFont(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurfaceVariant,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Divider(color: cs.outline, height: 1)),
                          ],
                        ),
                        const SizedBox(height: KuberSpacing.md),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _parsedItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: KuberSpacing.sm),
                          itemBuilder: (context, index) {
                            final item = _parsedItems[index];
                            return TransactionPreviewCard(
                              item: item,
                              dense: true,
                              isEditing: _editingIndex == index,
                              onEditToggle: () {
                                setState(() {
                                  _editingIndex = _editingIndex == index ? null : index;
                                });
                              },
                              onPickCategory: () => _openCategoryPicker(index),
                              onPickAccount: () => _openAccountPicker(index),
                              onCreateCategory: () => _handleCreateNewCategory(index),
                            );
                          },
                        ),
                        const SizedBox(height: KuberSpacing.md),
                      ] else ...[
                        // Empty State Examples
                        Text(
                          'WHAT YOU CAN TYPE',
                          style: localeFont(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: KuberSpacing.sm),
                        _buildExampleRow(cs, '250 in groceries', 'amount + category'),
                        _buildExampleRow(cs, '1200 rent from HDFC', 'amount + category + account'),
                        _buildExampleRow(cs, '300 movies and 500 dinner', 'multiple transactions'),
                        const SizedBox(height: KuberSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(KuberRadius.md),
                            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.mic_none_rounded, size: 16, color: cs.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Or tap the mic and just say it out loud.',
                                style: localeFont(fontSize: 13, color: cs.primary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Missing Account Error Card
                      if (missingAccountError) ...[
                        const SizedBox(height: KuberSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(KuberSpacing.md),
                          decoration: BoxDecoration(
                            color: cs.error.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(KuberRadius.lg),
                            border: Border.all(color: cs.error.withValues(alpha: 0.35)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: 20, color: cs.error),
                                  const SizedBox(width: 8),
                                  Text(
                                    'No default account set',
                                    style: localeFont(fontSize: 14, fontWeight: FontWeight.w700, color: cs.error),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Set a default account in settings or specify an account hint (e.g. "from HDFC").',
                                style: localeFont(fontSize: 13, color: cs.onSurfaceVariant, height: 1.4),
                              ),
                              const SizedBox(height: KuberSpacing.md),
                              AppButton(
                                label: 'Set default account',
                                type: AppButtonType.primary,
                                onPressed: () => context.push('/more/settings'),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // Pinned Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(KuberSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border(top: BorderSide(color: cs.outline)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 104,
                      child: AppButton(
                        label: 'Cancel',
                        type: AppButtonType.outline,
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: _parsedItems.length > 1
                            ? 'Add ${_parsedItems.length} transactions'
                            : 'Add transaction',
                        type: AppButtonType.primary,
                        onPressed: canSubmit ? _handleSave : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Voice Overlay Stack
        if (_showVoiceOverlay)
          VoiceOverlay(
            onTranscriptCaptured: (transcript) {
              setState(() {
                _showVoiceOverlay = false;
                _sourceType = 'voice';
                _inputController.text = transcript;
              });
            },
            onCancel: () {
              setState(() => _showVoiceOverlay = false);
            },
          ),
      ],
    );
  }

  Widget _buildExampleRow(ColorScheme cs, String text, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '"$text"',
            style: localeFont(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
          ),
          const Spacer(),
          Text(
            label,
            style: localeFont(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
