import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../data/account.dart';
import '../widgets/account_form.dart';

class AddEditAccountScreen extends ConsumerWidget {
  final Account? account;

  const AddEditAccountScreen({super.key, this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: KuberAppBar(
        showBack: true,
        title: account == null ? context.l10n.addAccount : context.l10n.editAccount,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AccountForm(
            account: account,
            onSave: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
