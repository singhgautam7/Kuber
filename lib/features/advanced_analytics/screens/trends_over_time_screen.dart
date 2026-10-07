import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../pro/feature_gates/gate_sheet_advanced_analytics.dart';
import '../../pro/paywall/pro_state.dart';
import '../widgets/trends_over_time_section.dart';

class TrendsOverTimeScreen extends ConsumerStatefulWidget {
  const TrendsOverTimeScreen({super.key});

  @override
  ConsumerState<TrendsOverTimeScreen> createState() =>
      _TrendsOverTimeScreenState();
}

class _TrendsOverTimeScreenState extends ConsumerState<TrendsOverTimeScreen> {
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
          header: KuberAppBar(title: 'Year over year', showBack: true),
          body: SizedBox.shrink(),
        ),
      );
    }

    return const Scaffold(
      body: KuberScrollAwayHeader(
        header: KuberAppBar(title: 'Year over year', showBack: true),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: KuberSpace.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TrendsOverTimeSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
