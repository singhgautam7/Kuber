import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../providers/settings_provider.dart';

/// Shows a bottom sheet to select a currency.
/// Used in both Settings and Onboarding for consistency.
void showCurrencyPicker({
  required BuildContext context,
  required WidgetRef ref,
  required String currentCode,
  required Function(String) onSelected,
}) {
  final cs = Theme.of(context).colorScheme;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: cs.surfaceContainer,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(28),
      ),
      side: BorderSide(color: cs.outline),
    ),
    builder: (ctx) {
      final sheetCs = Theme.of(ctx).colorScheme;
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) {
          return Column(
            children: [
              const SizedBox(height: KuberSpacing.md),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetCs.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
              Text(
                'Select Currency',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: sheetCs.onSurface,
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: kCurrencies.length,
                  itemBuilder: (ctx, i) {
                    final c = kCurrencies[i];
                    final isSelected = c.code == currentCode;
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? sheetCs.primaryContainer
                              : sheetCs.surfaceContainerHigh,
                          borderRadius:
                              BorderRadius.circular(KuberRadius.md),
                        ),
                        child: Text(
                          c.symbol,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? sheetCs.primary
                                : sheetCs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      title: Text(
                        c.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: sheetCs.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        c.code,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: sheetCs.onSurfaceVariant,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_rounded,
                              color: sheetCs.primary, size: 20)
                          : null,
                      onTap: () {
                        onSelected(c.code);
                        ref.read(settingsProvider.notifier).setCurrency(c.code);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
