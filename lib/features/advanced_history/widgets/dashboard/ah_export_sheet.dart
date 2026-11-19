import 'dart:typed_data';

import 'package:kuber/core/motion/kuber_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/save_file_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/timed_snackbar.dart';
import '../../../accounts/providers/account_provider.dart';
import '../../../categories/providers/category_provider.dart';
import '../../../export/providers/export_provider.dart';
import '../../../investments/providers/investment_provider.dart';
import '../../../loans/providers/loan_provider.dart';
import '../../../recurring/providers/recurring_provider.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../../transactions/data/transaction.dart';
import '../../../transactions/providers/transaction_provider.dart';
import '../../providers/ah_providers.dart';
import '../../query/query_labels.dart';
import 'ah_sheets.dart';

Future<void> showAhExportSheet(BuildContext context) =>
    ahShowSheet<void>(context, (_) => AhExportSheet(host: context));

/// Export results (CSV): exactly the matching transactions, in the History
/// CSV columns. Grouping and charts are not exported.
class AhExportSheet extends ConsumerStatefulWidget {
  const AhExportSheet({super.key, required this.host});
  final BuildContext host;

  @override
  ConsumerState<AhExportSheet> createState() => _AhExportSheetState();
}

class _AhExportSheetState extends ConsumerState<AhExportSheet> {
  bool _busy = false;

  String _fileName() {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return 'kuber_advanced_history_${n.year}-${two(n.month)}-${two(n.day)}.csv';
  }

  Future<Uint8List> _csv() async {
    // Every matching row: fetched by id, in chunks, from the id list the
    // page's query already produced (no second query).
    final txns = await ref.read(ahTxnPagesProvider(null).notifier).allMatching();
    final accounts = await ref.read(accountMapProvider.future);
    final cats = await ref.read(categoryMapProvider.future);
    final all = await ref.read(transactionListProvider.future);
    final currency = ref.read(currencyProvider);
    final rules = {
      for (final r in ref.read(recurringListProvider).valueOrNull ?? const [])
        '${r.id}': r.name
    };
    final loans = {
      for (final x in ref.read(loanListProvider).valueOrNull ?? const [])
        x.uid: x.name
    };
    final invs = {
      for (final x in ref.read(investmentListProvider).valueOrNull ?? const [])
        x.uid: x.name
    };
    String? sourceOf(Transaction t) {
      final id = t.sourceId;
      if (id == null) return null;
      return switch (t.sourceType) {
        'recurring' => 'Recurring: ${rules[id] ?? 'deleted'}',
        'loan' => 'Loan: ${loans[id] ?? 'deleted'}',
        'investment' => 'Investment: ${invs[id] ?? 'deleted'}',
        _ => null,
      };
    }

    return buildTransactionsCsvBytes(
      txns,
      accountNames: {for (final a in accounts.values) a.id.toString(): a.name},
      categoryMap: cats,
      currencyCode: currency.code,
      currencySymbol: currency.symbol,
      allTransactions: all,
      sourceOf: sourceOf,
    );
  }

  Future<void> _run(bool share) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = context.l10n;
    final host = widget.host;
    final nav = Navigator.of(context, rootNavigator: true);
    try {
      final bytes = await _csv();
      final name = _fileName();
      if (share) {
        await SharePlus.instance.share(ShareParams(files: [
          XFile.fromData(bytes, name: name, mimeType: 'text/csv')
        ], fileNameOverrides: [
          name
        ]));
        KuberHaptics.confirm();
        if (mounted) nav.pop();
      } else {
        if (!host.mounted) return;
        final r = await saveUserFile(host,
            bytes: bytes, fileName: name, extensions: const ['csv']);
        if (r == SaveFileResult.saved) {
          KuberHaptics.confirm();
          if (mounted) nav.pop();
          if (host.mounted) showKuberSnackBar(host, l.ahdExportSaved);
        }
      }
    } catch (_) {
      if (host.mounted) {
        showKuberSnackBar(host, l.ahdExportFailed, isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _readback(BuildContext context) {
    final l = context.l10n;
    final view = ref.read(ahViewProvider);
    final node = view.node;
    if (node == null) return l.ahdExportNoFilter;
    final fmt = ref.read(formatterProvider);
    try {
      return readbackOf(node, l, (v) => fmt.formatCurrency(v));
    } catch (_) {
      return view.queryText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final n = ref.watch(ahKpisProvider).valueOrNull?.transactions ?? 0;
    return KuberBottomSheet(
      title: l.ahdExportTitle,
      subtitle: l.ahdTxnN(n),
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: l.ahdExportSave,
            icon: Icons.folder_open_rounded,
            type: AppButtonType.primary,
            fullWidth: true,
            isLoading: _busy,
            onPressed: n == 0 ? null : () => _run(false),
          ),
          const SizedBox(height: KuberSpace.sm),
          AppButton(
            label: l.ahdExportShare,
            icon: Icons.share_rounded,
            type: AppButtonType.normal,
            fullWidth: true,
            onPressed: n == 0 || _busy ? null : () => _run(true),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.ahdExportFilter.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  letterSpacing: 0.8, color: cs.onSurfaceVariant)),
          const SizedBox(height: KuberSpace.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KuberSpace.md),
            decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: KuberShape.mediumR),
            child: Text(_readback(context),
                style: localeFont(fontSize: 15, color: cs.onSurface, height: 1.4)),
          ),
          const SizedBox(height: KuberSpace.lg),
          Text(l.ahdExportNote(ref.read(formatterProvider).formatNumber(n)),
              style: localeFont(
                  fontSize: 14, color: cs.onSurfaceVariant, height: 1.4)),
        ],
      ),
    );
  }
}
