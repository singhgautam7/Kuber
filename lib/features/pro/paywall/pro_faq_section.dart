import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_expandable_card.dart';
import '../../../shared/widgets/kuber_list.dart';

/// Frequently asked questions at the bottom of the Pro page. Every answer is
/// checked against the code and Play billing (specs/nov-release/decisions.md).
class ProFaqSection extends StatelessWidget {
  const ProFaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      (l.proFaqLifetimeQ, l.proFaqLifetimeA),
      (l.proFaqIncludedQ, l.proFaqIncludedA),
      (l.proFaqDevicesQ, l.proFaqDevicesA),
      (l.proFaqCancelQ, l.proFaqCancelA),
      (l.proFaqEndsQ, l.proFaqEndsA),
      (l.proFaqPhoneQ, l.proFaqPhoneA),
      (l.proFaqPromoQ, l.proFaqPromoA),
      (l.proFaqSecureQ, l.proFaqSecureA),
      (l.proFaqPaymentQ, l.proFaqPaymentA),
      (l.proFaqRefundQ, l.proFaqRefundA),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KuberSectionHeader(title: l.proFaqTitle),
        for (final (q, a) in items) ...[
          KuberExpandableCard(title: q, body: a),
          const SizedBox(height: KuberSpace.sm),
        ],
      ],
    );
  }
}
