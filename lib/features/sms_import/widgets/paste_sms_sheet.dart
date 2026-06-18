import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
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
    showSmsReviewSheet(hostContext, staged);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canReview = _state == _PasteState.parsed;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.84,
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KuberRadius.lg),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header + text area + live preview share one scrollable region so
            // nothing fixed forces an overflow when the keyboard is open.
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Paste an SMS',
                            style: localeFont(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Long-press your bank SMS, copy, and paste here. '
                            'Kuber parses it locally.',
                            style: localeFont(
                              fontSize: 12.5,
                              color: cs.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Text area — single bordered box; the field fills it.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                      child: SizedBox(
                        height: 150,
                        child: Container(
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(KuberRadius.md),
                            border: Border.all(
                              color: _state == _PasteState.otp
                                  ? context.kuberColors.warning
                                      .withValues(alpha: 0.5)
                                  : cs.primary,
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: _controller,
                            onChanged: _onChanged,
                            autofocus: true,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              height: 1.5,
                              color: cs.onSurface,
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(14),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              hintText:
                                  'e.g. "INR 648.50 debited from A/c XX4521 '
                                  'on 05-Jun-26..."',
                              hintStyle: GoogleFonts.jetBrainsMono(
                                fontSize: 13,
                                height: 1.5,
                                color:
                                    cs.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                      child: _buildBody(cs),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: Column(
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
                      label: 'Review this transaction',
                      type: AppButtonType.primary,
                      fullWidth: true,
                      onPressed: canReview ? _review : null,
                    ),
                  if (_state == _PasteState.otp) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Disabled while an OTP is detected.',
                      textAlign: TextAlign.center,
                      style: localeFont(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    switch (_state) {
      case _PasteState.empty:
        return Row(
          children: [
            Icon(Icons.shield_outlined, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Parsed on-device. Nothing is sent anywhere.',
                style: localeFont(fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ),
          ],
        );
      case _PasteState.parsing:
        return Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'Parsing…',
              style: localeFont(fontSize: 12.5, color: cs.onSurfaceVariant),
            ),
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

class _ParsedPreview extends ConsumerWidget {
  final SmsParseResult result;
  const _ParsedPreview({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final amountColor =
        result.type == 'income' ? cs.tertiary : cs.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_rounded, size: 14, color: cs.tertiary),
            const SizedBox(width: 8),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Matched '),
                  TextSpan(
                    text: result.patternMatched,
                    style: GoogleFonts.jetBrainsMono(color: cs.onSurface),
                  ),
                ],
              ),
              style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Mini list-card preview matching the import card anatomy.
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmsTypeGlyph(type: result.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            result.merchant ?? 'Transaction',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: localeFont(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          signedAmount(ref, result.amount, result.type),
                          style: localeFont(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: amountColor,
                          ).copyWith(fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ]),
                        ),
                      ],
                    ),
                    if (result.accountSuffix != null) ...[
                      const SizedBox(height: 7),
                      SmsChip(label: '····${result.accountSuffix}'),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OtpWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final warning = context.kuberColors.warning;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: warning.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: warning.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.lock_outline_rounded, size: 22, color: warning),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This looks like an OTP.',
                  style: localeFont(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kuber never imports messages with verification codes. Paste '
                  'a transaction confirmation instead.',
                  style: localeFont(
                    fontSize: 12.5,
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outline),
              ),
              child: Icon(Icons.info_outline_rounded,
                  size: 26, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            Text(
              "Couldn't read this message.",
              style: localeFont(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No amount or transaction type found. Try pasting the full '
              'original message from your bank.',
              textAlign: TextAlign.center,
              style: localeFont(
                fontSize: 12.5,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
