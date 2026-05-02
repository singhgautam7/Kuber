import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../widgets/calculator_widgets.dart';
import 'providers/exchange_rates_provider.dart';

class CurrencyConverterScreen extends ConsumerStatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  ConsumerState<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState
    extends ConsumerState<CurrencyConverterScreen> {
  final _amountCtrl = TextEditingController(text: '1');
  String _fromCurrency = 'USD';
  String _toCurrency = 'INR';
  bool _refreshRequested = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _swap() {
    setState(() {
      final tmp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = tmp;
    });
  }

  void _refresh() {
    setState(() => _refreshRequested = true);
    ref.invalidate(exchangeRatesProvider(_fromCurrency));
  }

  void _pickCurrency(bool isFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CurrencyPickerSheet(
        currentCode: isFrom ? _fromCurrency : _toCurrency,
        onSelected: (code) => setState(() {
          if (isFrom) {
            _fromCurrency = code;
          } else {
            _toCurrency = code;
          }
        }),
      ),
    );
  }

  String _formatLastUpdated(String raw, bool isStale) {
    // Try full ISO8601 first (cached fetch time), then date-only (API response)
    DateTime? dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    final dateStr = DateFormat('d MMM yyyy').format(dt);
    final timeStr = DateFormat('h:mm a').format(dt);
    // API date strings have no time component — don't show 12:00 AM for those
    final hasTime = raw.contains('T');
    return hasTime ? '$dateStr, $timeStr' : dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ratesAsync = ref.watch(exchangeRatesProvider(_fromCurrency));

    ref.listen(exchangeRatesProvider(_fromCurrency), (previous, next) {
      if (!_refreshRequested) return;
      if (next.isLoading) return;
      setState(() => _refreshRequested = false);
      next.when(
        loading: () {},
        error: (_, __) => showKuberSnackBar(
          context,
          'No network. Please check your internet connection',
          isError: true,
        ),
        data: (result) => result.isFetchedFromNetwork
            ? showKuberSnackBar(context, 'Exchange rates refreshed')
            : showKuberSnackBar(
                context,
                'No network. Please check your internet connection',
                isError: true,
              ),
      );
    });

    final isStale = ratesAsync.valueOrNull?.isStale ?? false;
    final rawLastUpdated = ratesAsync.valueOrNull?.lastUpdated;
    final lastUpdatedLabel = rawLastUpdated != null
        ? _formatLastUpdated(rawLastUpdated, isStale)
        : '—';

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(
              title: '',
              showBack: true,
              showHome: true,
              infoConfig: InfoConstants.currencyConverter,
            ),
          ),
          SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Currency Converter',
              description: 'Convert between currencies live',
              actionIcon: Icons.refresh_rounded,
              onAction: _refresh,
              actionTooltip: 'Refresh rates',
              isLoading: ratesAsync.isLoading || ratesAsync.isRefreshing,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              KuberSpacing.lg,
              0,
              KuberSpacing.lg,
              KuberSpacing.xl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Last updated label
                Padding(
                  padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                      children: [
                        TextSpan(
                          text: isStale ? 'CACHED · ' : 'LAST UPDATED: ',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        TextSpan(
                          text: lastUpdatedLabel,
                          style: TextStyle(color: isStale ? cs.error : cs.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                ToolInputCard(
                  children: [
                    ToolTextField(
                      label: 'AMOUNT',
                      controller: _amountCtrl,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _CurrencySelector(
                            label: 'FROM',
                            code: _fromCurrency,
                            onTap: () => _pickCurrency(true),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: KuberSpacing.md),
                          child: IconButton(
                            onPressed: _swap,
                            icon: Icon(Icons.swap_horiz_rounded,
                                color: cs.primary),
                            style: IconButton.styleFrom(
                              backgroundColor: cs.surfaceContainerHigh,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(KuberRadius.md),
                                side: BorderSide(color: cs.outline),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: _CurrencySelector(
                            label: 'TO',
                            code: _toCurrency,
                            onTap: () => _pickCurrency(false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                ToolResultCard(
                  children: [
                    ratesAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(KuberSpacing.xl),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (e, _) => _ErrorState(onRetry: _refresh),
                      data: (result) {
                        final amount =
                            double.tryParse(_amountCtrl.text) ?? 1;
                        final rate = result.rates[_toCurrency] ?? 1;
                        final converted = amount * rate;
                        final fromRate = result.rates[_fromCurrency] ?? 1;
                        final unitRate = rate / fromRate;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ToolHeroResult(
                              label: 'Converted Amount',
                              value:
                                  '${_currencySymbol(_toCurrency)}${converted.toStringAsFixed(2)}',
                              color: cs.primary,
                            ),
                            const SizedBox(height: KuberSpacing.lg),
                            ToolStatRow(
                              label: 'Exchange Rate',
                              value:
                                  '1 $_fromCurrency = ${unitRate.toStringAsFixed(4)} $_toCurrency',
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyPickerSheet extends StatefulWidget {
  final String currentCode;
  final ValueChanged<String> onSelected;

  const _CurrencyPickerSheet({
    required this.currentCode,
    required this.onSelected,
  });

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  String _query = '';

  static final _nameMap = {
    for (final c in kCurrencies) c.code: c.name,
  };

  List<String> get _filtered {
    final q = _query.toLowerCase();
    if (q.isEmpty) return kFrankfurterCurrencies;
    return kFrankfurterCurrencies
        .where((code) =>
            code.toLowerCase().contains(q) ||
            (_nameMap[code] ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Currency',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: () =>
                            Navigator.of(context, rootNavigator: true).pop(),
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.surfaceContainerHigh,
                          padding: const EdgeInsets.all(8),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 0.5, color: cs.outline),
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    KuberSpacing.lg, KuberSpacing.md, KuberSpacing.lg, 0),
                child: TextField(
                  autofocus: false,
                  onChanged: (v) => setState(() => _query = v),
                  style:
                      GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search currencies...',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 14, color: cs.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: cs.onSurfaceVariant, size: 20),
                    filled: true,
                    fillColor: cs.surfaceContainerHigh,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: KuberSpacing.md,
                      horizontal: KuberSpacing.lg,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      borderSide: BorderSide(color: cs.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              // List
              Expanded(
                child: ListView.builder(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: KuberSpacing.lg,
                      vertical: KuberSpacing.sm),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final code = filtered[i];
                    final name = _nameMap[code] ?? code;
                    final selected = code == widget.currentCode;
                    return ListTile(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        widget.onSelected(code);
                      },
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: KuberSpacing.sm),
                      title: Text(
                        code,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      trailing: selected
                          ? Icon(Icons.check_rounded,
                              color: cs.primary, size: 20)
                          : null,
                      dense: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  final String label;
  final String code;
  final VoidCallback onTap;

  const _CurrencySelector({
    required this.label,
    required this.code,
    required this.onTap,
  });

  static final _nameMap = {
    for (final c in kCurrencies) c.code: c.name,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final name = _nameMap[code] ?? code;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ToolInputLabel(label),
          const SizedBox(height: KuberSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: KuberSpacing.md,
              vertical: KuberSpacing.md,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _currencySymbol(String code) {
  const symbols = {
    'USD': '\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥', 'INR': '₹',
    'CNY': '¥', 'KRW': '₩', 'BRL': 'R\$', 'MXN': 'MX\$', 'CAD': 'CA\$',
    'AUD': 'A\$', 'CHF': 'Fr', 'HKD': 'HK\$', 'SGD': 'S\$', 'NOK': 'kr',
    'SEK': 'kr', 'DKK': 'kr', 'NZD': 'NZ\$', 'ZAR': 'R', 'TRY': '₺',
    'PLN': 'zł', 'THB': '฿', 'PHP': '₱', 'MYR': 'RM', 'IDR': 'Rp',
    'ILS': '₪', 'CZK': 'Kč', 'HUF': 'Ft', 'RON': 'lei', 'BGN': 'лв',
    'ISK': 'kr',
  };
  return symbols[code] ?? '';
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 40, color: cs.onSurfaceVariant),
            const SizedBox(height: KuberSpacing.md),
            Text(
              'Could not load exchange rates',
              style: GoogleFonts.inter(
                  fontSize: 14, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KuberSpacing.md),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: TextButton.styleFrom(foregroundColor: cs.primary),
            ),
          ],
        ),
      ),
    );
  }
}
