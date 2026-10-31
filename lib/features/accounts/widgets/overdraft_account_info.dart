import 'package:flutter/material.dart';

import '../../../core/models/info_config.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';

/// The Overdraft type's "i" sheet.
void showOverdraftInfo(BuildContext context) {
  final l = context.l10n;
  KuberInfoBottomSheet.show(
      context,
      KuberInfoConfig(
          title: l.accountTypeOverdraft, description: l.accountOverdraftInfoLine, actionLabel: l.gotIt));
}
