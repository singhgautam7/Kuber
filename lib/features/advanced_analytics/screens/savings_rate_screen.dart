import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../pro/feature_gates/gate_sheet_advanced_analytics.dart';
import '../../pro/paywall/pro_state.dart';
import '../widgets/savings_rate_section.dart';

class SavingsRateScreen extends ConsumerStatefulWidget {
  const SavingsRateScreen({super.key});

  @override
  ConsumerState<SavingsRateScreen> createState() => _SavingsRateScreenState();
}

class _SavingsRateScreenState extends ConsumerState<SavingsRateScreen> {
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
          header: KuberAppBar(title: 'Savings rate tracker', showBack: true),
          body: SizedBox.shrink(),
        ),
      );
    }

    return const Scaffold(
      body: KuberScrollAwayHeader(
        header: KuberAppBar(title: 'Savings rate tracker', showBack: true),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: KuberSpace.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SavingsRateSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
