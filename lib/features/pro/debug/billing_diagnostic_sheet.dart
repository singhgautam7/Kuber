import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
// Transitive with in_app_purchase; imported directly for the read-only
// queryPastPurchases() addition and the GooglePlayPurchaseDetails fields.
// ignore: depend_on_referenced_packages
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/info_table.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../paywall/pro_state.dart';
import '../services/purchase_service.dart';

/// DEBUG-ONLY read-only Play Billing inspector. Reached from Dev Tools; the
/// whole feature is compiled out of release builds (the call site is gated on
/// [kDebugMode], same as the Entitlement Override). Never ships to users.
///
/// Calls [InAppPurchaseAndroidPlatformAddition.queryPastPurchases] — a direct
/// `queryPurchases()` read that does NOT route through the app's grant listener
/// — and renders every returned purchase alongside the resolver's view of
/// entitlement, so a mismatched / unacknowledged / renamed product id is
/// visible at a glance. Nothing is written; entitlement is never mutated here.
void showBillingDiagnosticSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _BillingDiagnosticSheet(),
  );
}

class _BillingDiagnosticSheet extends ConsumerStatefulWidget {
  const _BillingDiagnosticSheet();

  @override
  ConsumerState<_BillingDiagnosticSheet> createState() =>
      _BillingDiagnosticSheetState();
}

/// Flattened, display-ready snapshot of one returned purchase.
class _PurchaseSnapshot {
  final String productId;
  final String orderId;
  final String status;
  final bool isAcknowledged;
  final bool pendingCompletePurchase;
  final String transactionDate;
  final bool grantsProByResolver;

  const _PurchaseSnapshot({
    required this.productId,
    required this.orderId,
    required this.status,
    required this.isAcknowledged,
    required this.pendingCompletePurchase,
    required this.transactionDate,
    required this.grantsProByResolver,
  });
}

class _BillingDiagnosticSheetState
    extends ConsumerState<_BillingDiagnosticSheet> {
  bool _loading = true;
  String? _error;
  List<_PurchaseSnapshot> _purchases = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_run());
  }

  Future<void> _run() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final addition = InAppPurchase.instance
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final resp = await addition.queryPastPurchases().timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('queryPurchases timed out after 10s'),
          );

      final snapshots = resp.pastPurchases.map((p) {
        final wrapper = p.billingClientPurchase;
        return _PurchaseSnapshot(
          productId: p.productID,
          orderId: wrapper.orderId.isNotEmpty ? wrapper.orderId : '—',
          status: p.status.name,
          isAcknowledged: wrapper.isAcknowledged,
          pendingCompletePurchase: p.pendingCompletePurchase,
          transactionDate: _formatDate(p.transactionDate),
          grantsProByResolver: planForProductId(p.productID) != null,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _purchases = snapshots;
        _loading = false;
        _error = resp.error?.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// Android reports `transactionDate` as epoch-milliseconds-as-string.
  String _formatDate(String? raw) {
    if (raw == null) return '—';
    final ms = int.tryParse(raw);
    if (ms == null) return raw;
    return DateTime.fromMillisecondsSinceEpoch(ms).toIso8601String();
  }

  String _buildCopyText(KuberProState pro) {
    final b = StringBuffer();
    b.writeln('=== KUBER BILLING DIAGNOSTIC ===');
    b.writeln('Resolver knows Pro ids: ${kProProductIds.join(', ')}');
    b.writeln('isPro (resolver): ${pro.isPro}');
    b.writeln('source: ${pro.source.name}');
    b.writeln('plan: ${pro.plan?.name ?? '—'}');
    b.writeln(
      'triggering productId: '
      '${pro.plan == null ? '—' : productIdForPlan(pro.plan!)}',
    );
    b.writeln('--------------------------------');
    if (_error != null) b.writeln('queryPurchases error: $_error');
    b.writeln('purchases returned: ${_purchases.length}');
    for (final p in _purchases) {
      b.writeln('- productID: ${p.productId}');
      b.writeln('  orderID: ${p.orderId}');
      b.writeln('  status: ${p.status}');
      b.writeln('  acknowledged: ${p.isAcknowledged}');
      b.writeln('  pendingCompletePurchase: ${p.pendingCompletePurchase}');
      b.writeln('  transactionDate: ${p.transactionDate}');
      b.writeln('  grantsProByResolver: ${p.grantsProByResolver}');
    }
    b.writeln('================================');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pro = ref.watch(kuberProStateProvider);

    return KuberBottomSheet(
      title: 'Billing diagnostic',
      subtitle: 'Debug builds only',
      actions: _actions(cs, pro),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Read-only queryPurchases() snapshot. Nothing is written and '
            'entitlement is never changed here. Long-press any row, or use '
            'Copy report, to share.',
            style: localeFont(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),

          // Resolved entitlement (what the app currently thinks).
          _label(cs, 'RESOLVED ENTITLEMENT'),
          const SizedBox(height: KuberSpacing.sm),
          InfoTable(
            rows: [
              InfoTableHighlightRow(
                label: 'Pro active',
                value: pro.isPro ? 'Yes' : 'No',
                valueColor: pro.isPro ? cs.tertiary : cs.error,
              ),
              InfoTableDataRow(label: 'Source', value: pro.source.name),
              InfoTableDataRow(label: 'Plan', value: pro.plan?.name ?? '—'),
              InfoTableDataRow(
                label: 'Triggered by',
                value: pro.plan == null ? '—' : productIdForPlan(pro.plan!),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.lg),

          _label(cs, 'PLAY PURCHASES (queryPurchases)'),
          const SizedBox(height: KuberSpacing.sm),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: KuberSpacing.xl),
              child: Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            )
          else ...[
            if (_error != null) ...[
              InfoTable(
                rows: [
                  InfoTableLabelOnlyRow(label: 'Query error', value: _error!),
                ],
              ),
              const SizedBox(height: KuberSpacing.md),
            ],
            if (_purchases.isEmpty)
              InfoTable(
                rows: const [
                  InfoTableLabelOnlyRow(
                    value: 'queryPurchases() returned no owned purchases on '
                        'this device / Play account.',
                  ),
                ],
              )
            else
              for (var i = 0; i < _purchases.length; i++) ...[
                if (i > 0) const SizedBox(height: KuberSpacing.md),
                _purchaseCard(cs, _purchases[i]),
              ],
          ],
        ],
      ),
    );
  }

  Widget _actions(ColorScheme cs, KuberProState pro) {
    return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _loading ? null : _run,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Re-query',
                style: localeFont(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: FilledButton(
              onPressed: _loading
                  ? null
                  : () async {
                      await Clipboard.setData(
                        ClipboardData(text: _buildCopyText(pro)),
                      );
                      if (!mounted) return;
                      showKuberSnackBar(context, 'Billing diagnostic copied');
                    },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Copy report',
                style: localeFont(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
    );
  }

  Widget _purchaseCard(ColorScheme cs, _PurchaseSnapshot p) {
    // Flag the exact failure the resolver would hit: a purchase Play returns
    // whose product id is not in kProProductIds silently grants nothing.
    final grantColor = p.grantsProByResolver ? cs.tertiary : cs.error;
    return InfoTable(
      rows: [
        InfoTableDataRow(
          label: 'productID',
          value: p.productId,
          onLongPress: () => _copy(p.productId, 'productID'),
        ),
        InfoTableDataRow(
          label: 'orderID',
          value: p.orderId,
          onLongPress: () => _copy(p.orderId, 'orderID'),
        ),
        InfoTableDataRow(label: 'status', value: p.status),
        InfoTableDataRow(
          label: 'acknowledged',
          value: p.isAcknowledged ? 'true' : 'false',
        ),
        InfoTableDataRow(
          label: 'pendingComplete',
          value: p.pendingCompletePurchase ? 'true' : 'false',
        ),
        InfoTableDataRow(label: 'transactionDate', value: p.transactionDate),
        InfoTableHighlightRow(
          label: 'Grants Pro (resolver)',
          value: p.grantsProByResolver ? 'Yes' : 'No — id unknown',
          valueColor: grantColor,
        ),
      ],
    );
  }

  void _copy(String value, String what) {
    Clipboard.setData(ClipboardData(text: value));
    showKuberSnackBar(context, '$what copied');
  }

  Widget _label(ColorScheme cs, String text) => Text(
        text,
        style: localeFont(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: cs.onSurfaceVariant,
        ),
      );
}
