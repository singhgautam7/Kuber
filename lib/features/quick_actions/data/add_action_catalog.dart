import 'package:flutter/material.dart';

/// One add-entry action shown in the FAB long-press "Add New" sheet. `route`
/// is the go_router destination its row navigates to (the same add screens the
/// app already uses).
class AddActionMeta {
  final String id;
  final String label;
  final IconData icon;
  final String route;

  const AddActionMeta({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Full add-action catalog. The first three (expense/income/transfer) are the
/// non-removable core (see `kCoreAddActions`); the rest form the customizable
/// tail persisted in `addMenuActions`.
const List<AddActionMeta> kAddActionCatalog = [
  AddActionMeta(
    id: 'add_expense',
    label: 'Add Expense',
    icon: Icons.south_west_rounded,
    route: '/add-transaction?type=expense',
  ),
  AddActionMeta(
    id: 'add_income',
    label: 'Add Income',
    icon: Icons.north_east_rounded,
    route: '/add-transaction?type=income',
  ),
  AddActionMeta(
    id: 'transfer',
    label: 'Transfer',
    icon: Icons.swap_horiz_rounded,
    route: '/add-transaction?type=transfer',
  ),
  AddActionMeta(
    id: 'add_note',
    label: 'Add Note',
    icon: Icons.edit_note_rounded,
    route: '/notes/editor?id=new',
  ),
  AddActionMeta(
    id: 'add_recurring',
    label: 'Add Recurring',
    icon: Icons.autorenew_rounded,
    route: '/recurring/add',
  ),
  AddActionMeta(
    id: 'add_loan',
    label: 'Add Loan',
    icon: Icons.account_balance_rounded,
    route: '/loans/add',
  ),
  AddActionMeta(
    id: 'add_investment',
    label: 'Add Investment',
    icon: Icons.show_chart_rounded,
    route: '/investments/add',
  ),
  AddActionMeta(
    id: 'lend_borrow',
    label: 'Lend / Borrow',
    icon: Icons.handshake_rounded,
    route: '/ledger/add',
  ),
];

AddActionMeta? addActionById(String id) =>
    kAddActionCatalog.where((a) => a.id == id).firstOrNull;
