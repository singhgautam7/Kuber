import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../pro/feature_gates/gate_sheet_advanced_analytics.dart';
import '../../pro/paywall/pro_state.dart';
import '../widgets/about_analytics_info_sheet.dart';
import '../widgets/financial_health_score_section.dart';

class FinancialHealthScoreScreen extends ConsumerStatefulWidget {
  const FinancialHealthScoreScreen({super.key});

  @override
  ConsumerState<FinancialHealthScoreScreen> createState() =>
      _FinancialHealthScoreScreenState();
}

class _FinancialHealthScoreScreenState
    extends ConsumerState<FinancialHealthScoreScreen> {
  var _gateShown = false;

  @override
  Widget build(BuildContext context) {
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
        body: KuberScrollAwayHeader(
          header: KuberAppBar(title: 'Financial health score', showBack: true),
          body: SizedBox.shrink(),
        ),
      );
    }

    return const Scaffold(
      body: KuberScrollAwayHeader(
        header: KuberAppBar(
          title: 'Financial health score',
          showBack: true,
          infoConfig: kAboutAdvancedAnalyticsInfoConfig,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: KuberSpace.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: FinancialHealthScoreSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
