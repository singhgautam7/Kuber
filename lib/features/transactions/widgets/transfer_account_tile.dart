import 'package:flutter/material.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/locale_font.dart';

import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/account_helpers.dart';
import '../../accounts/data/account.dart';

class TransferAccountTile extends StatelessWidget {
  final String label;
  final Account? account;
  final VoidCallback onTap;

  const TransferAccountTile({
    super.key,
    required this.label,
    required this.account,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = account != null
        ? resolveAccountColor(account!)
        : cs.onSurfaceVariant;
    final icon = account != null
        ? resolveAccountIcon(account!)
        : Icons.account_balance_wallet_outlined;

    // From / To row inside one grouped list (board 3.4).
    return KuberListRow(
      onTap: onTap,
      leading: account != null
          ? CategoryIcon.square(icon: icon, rawColor: color)
          : KuberIconTile(icon: icon, tone: KuberTone.neutral),
      title: account?.name ?? context.l10n.selectAccountTitle,
      subtitle: sentenceCase(label),
      trailing: Icon(
        Icons.expand_more_rounded,
        size: 24,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}
