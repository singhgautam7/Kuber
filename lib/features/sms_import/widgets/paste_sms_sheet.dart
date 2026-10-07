import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart' show monoFont;
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/app_button.dart';
import '../engine/sms_parser.dart';
import '../providers/sms_import_provider.dart';
import '../screens/sms_import_widgets.dart';
import 'transaction_review_sheet.dart';

/// Opens the paste-an-SMS fallback sheet (Section 07).
void showPasteSmsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const PasteSmsSheet(),
  );
}

enum _PasteState { empty, parsing, parsed, otp, cantParse }

class PasteSmsSheet extends ConsumerStatefulWidget {
  const PasteSmsSheet({super.key});

  @override
  ConsumerState<PasteSmsSheet> createState() => _PasteSmsSheetState();
}

class _PasteSmsSheetState extends ConsumerState<PasteSmsSheet> {
  final _controller = TextEditingController();
  final _parser = const SmsParser();
  Timer? _debounce;
  _PasteState _state = _PasteState.empty;
  SmsParseResult? _result;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _state = _PasteState.empty;
        _result = null;
      });
      return;
    }
    // Immediate OTP feedback (no need to wait for the debounce).
    if (_parser.isOtp(trimmed)) {
      setState(() {
        _state = _PasteState.otp;
        _result = null;
      });
      return;
    }
    setState(() => _state = _PasteState.parsing);
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final result = _parser.parse(trimmed, 'PASTED', DateTime.now());
      if (!mounted) return;
      setState(() {
        if (result == null) {
          _state = _PasteState.cantParse;
          _result = null;
        } else {
          _state = _PasteState.parsed;
          _result = result;
        }
      });
    });
  }

  Future<void> _review() async {
    final result = _result;
    if (result == null) return;
    // Close the keyboard and drop focus before moving on.
    FocusManager.instance.primaryFocus?.unfocus();
    // Capture the host navigator/context before the async gap; `context` (the
    // sheet) is defunct once we pop it.
    final nav = Navigator.of(context);
    final hostContext = nav.context;
    final staged = await ref
        .read(smsImportProvider.notifier)
        .stageFromPaste(result);
    if (!hostContext.mounted) return;
    nav.pop(); // close paste sheet
    // Paste-a-SMS is always free and never counts toward the weekly cap.
    showSmsReviewSheet(hostContext, staged, countsTowardLimit: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final canReview = _state == _PasteState.parsed;
    final isOtp = _state == _PasteState.otp;
    final fieldBorder = OutlineInputBorder(
      borderRadius: KuberShape.largeR,
      borderSide: BorderSide(
        color: isOtp ? context.kuberMoney.warning : cs.primary,
        width: 2,
      ),
    );

    // Board 3.9a "Paste a single SMS": title + one-line description, a mono
    // multi-line field, the detected summary, Review.
    return KuberBottomSheet(
      title: 'Paste an SMS',
      description: 'Paste one bank message to import it',
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_state == _PasteState.cantParse)
            AppButton(
              label: 'Add manually instead',
              type: AppButtonType.outline,
              fullWidth: true,
              icon: Icons.add_rounded,
              onPressed: () {
                Navigator.pop(context);
                context.push('/add-transaction');
              },
            )
          else
            AppButton(
              label: 'Review',
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: canReview ? _review : null,
            ),
          if (isOtp) ...[
            const SizedBox(height: KuberSpace.sm),
            Text(
              'Disabled while an OTP is detected.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall!.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 132,
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              autofocus: true,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: monoFont(fontSize: 14, height: 1.5, color: cs.onSurface),
              decoration: InputDecoration(
                filled: true,
                fillColor: cs.surfaceContainerHigh,
                contentPadding: const EdgeInsets.all(16),
                border: fieldBorder,
                enabledBorder: fieldBorder,
                focusedBorder: fieldBorder,
                hintText:
                    'e.g. "INR 648.50 debited from A/c XX4521 on '
                    '05-Jun-26..."',
                hintStyle: monoFont(
                  fontSize: 14,
                  height: 1.5,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: KuberSpace.md),
          _buildBody(cs),
        ],
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    final small = Theme.of(
      context,
    ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant);
    switch (_state) {
      case _PasteState.empty:
        return Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: KuberSpace.sm),
            Expanded(
              child: Text(
                'Parsed on-device. Nothing is sent anywhere.',
                style: small,
              ),
            ),
          ],
        );
      case _PasteState.parsing:
        return Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: KuberSpace.sm),
            Text('Parsing…', style: small),
          ],
        );
      case _PasteState.parsed:
        return _ParsedPreview(result: _result!);
      case _PasteState.otp:
        return _OtpWarning();
      case _PasteState.cantParse:
        return _CantParse();
    }
  }
}

/// "Detected: expense ₹412 · Swiggy · ····4321" with a success check.
class _ParsedPreview extends ConsumerWidget {
  final SmsParseResult result;
  const _ParsedPreview({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final parts = [
      '${result.type} ${signedAmount(ref, result.amount, result.type).substring(1)}',
      if (result.merchant != null) result.merchant!,
      if (result.accountSuffix != null) '····${result.accountSuffix}',
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: context.kuberMoney.income,
        ),
        const SizedBox(width: KuberSpace.sm),
        Expanded(
          child: Text(
            'Detected: ${parts.join(' · ')}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _OtpWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final m = context.kuberMoney;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: m.warningContainer,
        borderRadius: KuberShape.largeR,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: m.onWarningContainer.withValues(alpha: 0.12),
              borderRadius: KuberShape.mediumR,
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: m.onWarningContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This looks like an OTP.',
                  style: tt.titleSmall!.copyWith(color: m.onWarningContainer),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kuber never imports messages with verification codes. Paste '
                  'a transaction confirmation instead.',
                  style: tt.bodySmall!.copyWith(color: m.onWarningContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CantParse extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const KuberEmptyState(
    icon: Icons.info_outline_rounded,
    title: "Couldn't read this message.",
    description:
        'No amount or transaction type found. Try pasting the '
        'full original message from your bank.',
  );
}
