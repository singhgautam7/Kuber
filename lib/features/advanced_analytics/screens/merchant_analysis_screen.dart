import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../pro/feature_gates/gate_sheet_advanced_analytics.dart';
import '../../pro/paywall/pro_state.dart';
import '../providers/advanced_analytics_provider.dart';
import '../widgets/merchant_analysis_section.dart';

class MerchantAnalysisScreen extends ConsumerStatefulWidget {
  const MerchantAnalysisScreen({super.key});

  @override
  ConsumerState<MerchantAnalysisScreen> createState() =>
      _MerchantAnalysisScreenState();
}

class _MerchantAnalysisScreenState
    extends ConsumerState<MerchantAnalysisScreen> {
  var _gateShown = false;
  final _scrollController = ScrollController();
  static const _pageSize = 10;
  int _displayedCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 300) {
      final data = ref.read(merchantAnalysisProvider).valueOrNull;
      if (data != null && _displayedCount < data.topMerchants.length) {
        setState(() {
          _displayedCount += _pageSize;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(merchantAnalysisProvider, (_, __) {
      if (_displayedCount != _pageSize) {
        setState(() => _displayedCount = _pageSize);
      }
    });

    final hasAccess = ref.watch(kuberProStateProvider).hasProAccess;
    if (!hasAccess && !_gateShown) {
      _gateShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showAdvancedAnalyticsGateSheet(context);
      });
    }
    if (!hasAccess) {
      return const Scaffold(
        appBar: KuberAppBar(showBack: true, showHome: true, showBrand: false),
        body: SizedBox.shrink(),
      );
    }

    return Scaffold(
      appBar: const KuberAppBar(
        showBack: true,
        showHome: true,
        showBrand: false,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: KuberSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const KuberPageHeader(
              title: 'Merchant analysis',
              description: 'Who you pay the most',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MerchantAnalysisSection(displayedCount: _displayedCount),
            ),
          ],
        ),
      ),
    );
  }
}
