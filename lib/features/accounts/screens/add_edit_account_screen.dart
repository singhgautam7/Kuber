import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        title: account == null ? 'Add Account' : 'Edit Account',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: AccountForm(
          account: account,
          onSave: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
