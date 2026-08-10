import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/card_palette.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/card_color_gradient_picker.dart';
import '../../../shared/widgets/icon_picker_bottom_sheet.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/widgets/settings_choice_sheet.dart';
import '../card_info_configs.dart';
import '../data/bank_icons.dart';
import '../data/card_vault_service.dart';
import '../data/stored_card.dart';
import '../providers/kuber_cards_provider.dart';
import '../widgets/card_icon.dart';
import '../widgets/cards_secure_scaffold.dart';
import '../widgets/stored_card_visual.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';

const _cardTypeChoices = <SettingsChoice<String>>[
  SettingsChoice(value: 'debit', label: 'Debit', icon: Icons.credit_card_rounded),
  SettingsChoice(value: 'credit', label: 'Credit', icon: Icons.credit_score_rounded),
  SettingsChoice(value: 'prepaid', label: 'Prepaid', icon: Icons.account_balance_wallet_rounded),
  SettingsChoice(value: 'forex', label: 'Forex', icon: Icons.currency_exchange_rounded),
  SettingsChoice(value: 'gift', label: 'Gift', icon: Icons.card_giftcard_rounded),
  SettingsChoice(value: 'travel', label: 'Travel', icon: Icons.flight_rounded),
  SettingsChoice(value: 'fuel', label: 'Fuel', icon: Icons.local_gas_station_rounded),
  SettingsChoice(value: 'meal', label: 'Meal', icon: Icons.restaurant_rounded),
  SettingsChoice(value: 'corporate', label: 'Corporate', icon: Icons.business_rounded),
  SettingsChoice(value: 'other', label: 'Others', icon: Icons.more_horiz_rounded),
];

const _networkChoices = <SettingsChoice<String>>[
  SettingsChoice(value: 'visa', label: 'Visa', icon: Icons.payment_rounded),
  SettingsChoice(value: 'mastercard', label: 'Mastercard', icon: Icons.payment_rounded),
  SettingsChoice(value: 'rupay', label: 'RuPay', icon: Icons.payment_rounded),
  SettingsChoice(value: 'amex', label: 'Amex', icon: Icons.payment_rounded),
  SettingsChoice(value: 'discover', label: 'Discover', icon: Icons.payment_rounded),
  SettingsChoice(value: 'other', label: 'Others', icon: Icons.payment_rounded),
];

const _riskyLabels = ['cvv', 'cvc', 'pin', 'otp', 'password', 'passcode', 'secret'];

class _CustomFieldRow {
  final TextEditingController label;
  final TextEditingController value;
  _CustomFieldRow({String label = '', String value = ''})
      : label = TextEditingController(text: label),
        value = TextEditingController(text: value);
  void dispose() {
    label.dispose();
    value.dispose();
  }
}

class AddEditCardScreen extends ConsumerStatefulWidget {
  final StoredCard? card;
  const AddEditCardScreen({super.key, this.card});

  @override
  ConsumerState<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends ConsumerState<AddEditCardScreen> {
  final _nickname = TextEditingController();
  final _cardholder = TextEditingController();
  final _number = _MaskedNumberController();
  final _expiry = TextEditingController();
  final _custom = <_CustomFieldRow>[];

  String? _cardType;
  String? _network;
  String? _bankIcon;
  int _colorValue = 0;
  bool _isGradient = false;
  bool _numberObscured = true;

  bool _loading = false;
  bool _riskyConfirmed = false;

  bool get _isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    _colorValue = CardPalette.solids.first;
    _nickname.addListener(_onFormChanged);
    _number.addListener(_onFormChanged);
    if (_isEditing) {
      _prefill();
    }
  }

  Future<void> _prefill() async {
    final card = widget.card!;
    setState(() {
      _bankIcon = card.bankIcon;
      _cardType = card.cardType;
      _network = card.network;
      _colorValue = card.colorValue;
      _isGradient = card.isGradient;
      _nickname.text = card.nickname;
      _loading = true;
    });
    final key = ref.read(cardSessionProvider).key;
    if (key == null) {
      setState(() => _loading = false);
      return;
    }
    final dec =
        await ref.read(cardVaultServiceProvider).decryptCard(key: key, card: card);
    if (!mounted) return;
    setState(() {
      _cardholder.text = dec.cardholder ?? '';
      _number.text = dec.number == null ? '' : _groupDigits(dec.number!);
      _expiry.text = dec.expiry ?? '';
      for (final f in dec.customFields) {
        _custom.add(_CustomFieldRow(label: f.label, value: f.value));
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nickname.dispose();
    _cardholder.dispose();
    _number.dispose();
    _expiry.dispose();
    for (final r in _custom) {
      r.dispose();
    }
    super.dispose();
  }

  void _onFormChanged() => setState(() {});

  bool get _canSave =>
      _nickname.text.trim().isNotEmpty && _number.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CardsSecureScaffold(
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: KuberAppBar(
          showBack: true,
          title: _isEditing ? 'Edit card' : 'Add card',
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _form(cs),
                ),
              ),
        bottomNavigationBar: KuberSaveButton(
          label: _isEditing ? 'Save changes' : 'Add card',
          onPressed: _canSave ? _onSave : null,
        ),
      ),
    );
  }

  Widget _form(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Live preview.
        StoredCardVisual(
          nickname: _nickname.text,
          last4: _deriveLast4(_number.text),
          bankIcon: _bankIcon,
          network: _network,
          colorValue: _colorValue,
          isGradient: _isGradient,
        ),

        // DETAILS
        KuberFormSection(
          label: 'Details',
          children: [
            _labeled('Nickname', _field(_nickname, hint: 'HDFC Regalia',
                capitalization: TextCapitalization.words)),
            _labeled(
              'Card number',
              _field(
                _number,
                hint: '•••• •••• •••• ••••',
                keyboardType: TextInputType.number,
                // Masking is done by the controller (digits -> •, spaces kept),
                // so the grouping survives while hidden. No obscureText here.
                obscure: false,
                inputFormatters: [_CardNumberFormatter()],
                suffix: IconButton(
                  icon: Icon(
                    _numberObscured
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() {
                    _numberObscured = !_numberObscured;
                    _number.obscure = _numberObscured;
                  }),
                ),
              ),
            ),
            _labeled('Cardholder name', _field(_cardholder, hint: 'John Doe',
              capitalization: TextCapitalization.words),
              optional: true),
            _labeled(
              'Expiry',
              _field(
                _expiry,
                hint: 'MM/YY',
                keyboardType: TextInputType.number,
                inputFormatters: [_ExpiryFormatter()],
              ),
              optional: true,
            ),
          ],
        ),

        // CLASSIFICATION
        KuberFormSection(
          label: 'Classification',
          children: [
            KuberPickerRow(
              leading: KuberLeadingSwatch(
                color: cs.primary,
                icon: _cardType == null
                    ? Icons.style_outlined
                    : _iconForType(_cardType!),
                empty: _cardType == null,
              ),
              label: 'Card type',
              value: _cardType == null ? 'Choose type' : _titleCase(_cardType!),
              valueIsPlaceholder: _cardType == null,
              onTap: _pickCardType,
            ),
            KuberPickerRow(
              leading: KuberLeadingSwatch(
                color: cs.primary,
                icon: Icons.payment_rounded,
                empty: _network == null,
              ),
              label: 'Network',
              value: _network == null ? 'Choose network' : _networkLabel(_network!),
              valueIsPlaceholder: _network == null,
              onTap: _pickNetwork,
            ),
          ],
        ),

        // APPEARANCE (icon first, then color)
        KuberFormSection(
          label: 'Appearance',
          children: [
            KuberPickerRow(
              leading: _bankIcon == null
                  ? KuberLeadingSwatch(
                      color: cs.primary, icon: Icons.account_balance_rounded,
                      empty: true)
                  : SizedBox(
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                        ),
                        alignment: Alignment.center,
                        child: CardIcon(
                            iconKey: _bankIcon, size: 18, color: cs.primary),
                      ),
                    ),
              label: 'Icon',
              value: _bankIcon == null ? 'Choose an icon' : 'Icon selected',
              valueIsPlaceholder: _bankIcon == null,
              clearable: _bankIcon != null,
              onClear: () => setState(() => _bankIcon = null),
              onTap: _pickIcon,
            ),
            KuberPickerRow(
              leading: Container(
                decoration: BoxDecoration(
                  color: _isGradient ? null : Color(_colorValue),
                  gradient: _isGradient
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            CardPalette.gradientColors(_colorValue).$1,
                            CardPalette.gradientColors(_colorValue).$2,
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
              ),
              label: 'Color',
              value: _isGradient
                  ? CardPalette.gradientNames[_colorValue]
                  : 'Solid color',
              onTap: () => showCardColorPicker(
                context: context,
                selectedValue: _colorValue,
                selectedIsGradient: _isGradient,
                onSelected: (value, isGradient) => setState(() {
                  _colorValue = value;
                  _isGradient = isGradient;
                }),
              ).unfocusOnComplete(context),
            ),
          ],
        ),

        // CUSTOM FIELDS
        KuberFormSection(
          label: 'Custom fields',
          trailing: IconButton(
            icon: Icon(Icons.info_outline_rounded,
                size: 18, color: cs.onSurfaceVariant),
            onPressed: () =>
                KuberInfoBottomSheet.show(context, aboutCustomFieldsInfo),
          ),
          children: [
            for (var i = 0; i < _custom.length; i++) _customFieldRow(cs, i),
            AppButton(
              label: 'Add custom field',
              type: AppButtonType.dotted,
              icon: Icons.add_rounded,
              fullWidth: true,
              onPressed: () => setState(() => _custom.add(_CustomFieldRow())),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _customFieldRow(ColorScheme cs, int i) {
    final row = _custom[i];
    // Standard inputs (same height/margins as the rest of the form): a Label
    // field with a delete affordance, then a Value field below.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _field(row.label, hint: 'Label')),
            const SizedBox(width: 4),
            IconButton(
              icon:
                  Icon(Icons.close_rounded, size: 20, color: cs.onSurfaceVariant),
              onPressed: () => setState(() {
                _custom.removeAt(i).dispose();
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _field(row.value, hint: 'Value'),
      ],
    );
  }

  // ── Field helpers ──────────────────────────────────────────────────────────

  Widget _labeled(String label, Widget field, {bool optional = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KuberFieldLabel(label, optional: optional),
        field,
      ],
    );
  }

  Widget _field(
    TextEditingController c, {
    String? hint,
    TextInputType? keyboardType,
    bool obscure = false,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffix,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      textCapitalization: capitalization,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: localeFont(fontSize: 15, color: cs.onSurface),
      decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
    );
  }

  // ── Pickers ──────────────────────────────────────────────────────────────────

  void _pickCardType() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsChoiceSheet<String>(
        title: 'Card type',
        choices: _cardTypeChoices,
        selectedValue: _cardType ?? '',
        onSelected: (v) => setState(() => _cardType = v),
      ),
    );
  }

  void _pickNetwork() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsChoiceSheet<String>(
        title: 'Network',
        choices: _networkChoices,
        selectedValue: _network ?? '',
        onSelected: (v) => setState(() => _network = v),
      ),
    );
  }

  void _pickIcon() {
    // Reuses the exact searchable icon picker from Add/Edit Account & Category,
    // fed three ordered sources: bundled bank monograms (first), then all the
    // existing Kuber account + category icons, plus a gallery option. Search
    // works across all of them. See specs/plans/kuber-cards.md §5.1.
    final keys = <String>[
      ...kBankIconKeys,
      ...{...IconMapper.kAccountIconKeys, ...IconMapper.kCategoryIconKeys}
          .where((k) => !kBankIconKeys.contains(k)),
    ];
    final tags = <String, List<String>>{
      ...IconMapper.kIconTags,
      ...kBankIconTags,
    };
    showIconPicker(
      context: context,
      iconKeys: keys,
      tags: tags,
      selected: _bankIcon,
      bankLabels: kBankIconLabels,
      allowGallery: true,
      onSelected: (key) => setState(() => _bankIcon = key),
    );
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    // Risky-label soft warning: fire once, non-blocking.
    if (!_riskyConfirmed && _hasRiskyLabel()) {
      final proceed = await _showRiskyDialog();
      if (proceed != true) return;
      _riskyConfirmed = true;
    }

    final key = ref.read(cardSessionProvider).key;
    if (key == null) return; // secure scaffold covers a locked state

    final input = CardInput(
      nickname: _nickname.text.trim(),
      number: _number.text.trim().isEmpty ? null : _number.text.trim(),
      cardholder: _cardholder.text.trim().isEmpty ? null : _cardholder.text.trim(),
      expiry: _expiry.text.trim().isEmpty ? null : _expiry.text.trim(),
      cardType: _cardType,
      network: _network,
      bankIcon: _bankIcon,
      colorValue: _colorValue,
      isGradient: _isGradient,
      customFields: [
        for (final r in _custom)
          if (r.label.text.trim().isNotEmpty || r.value.text.trim().isNotEmpty)
            CardCustomField(label: r.label.text.trim(), value: r.value.text.trim()),
      ],
    );

    await ref.read(cardVaultServiceProvider).saveCard(
          key: key,
          input: input,
          existing: widget.card,
        );
    await ref.read(storedCardsProvider.notifier).reload();
    if (!mounted) return;
    Navigator.pop(context);
    showKuberSnackBar(context, 'Card saved.');
  }

  bool _hasRiskyLabel() {
    for (final r in _custom) {
      final l = r.label.text.trim().toLowerCase();
      if (l.isNotEmpty && _riskyLabels.any((k) => l.contains(k))) return true;
    }
    return false;
  }

  Future<bool?> _showRiskyDialog() {
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title:
            Text('Storing sensitive values', style: localeFont(fontWeight: FontWeight.w700)),
        content: Text(
          'Kuber Cards is encrypted, but security codes like CVV, PIN, and OTP '
          'are safest kept out of any app. You can still save this if you want to.',
          style: localeFont(color: cs.onSurfaceVariant, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: localeFont()),
          ),
          AppButton(
            label: 'Save anyway',
            type: AppButtonType.primary,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
  }

  // ── Misc ─────────────────────────────────────────────────────────────────────

  IconData _iconForType(String type) =>
      _cardTypeChoices.firstWhere((c) => c.value == type).icon;

  String _networkLabel(String v) =>
      _networkChoices.firstWhere((c) => c.value == v).label;

  String _titleCase(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String? _deriveLast4(String number) {
    final digits = number.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    return digits.length <= 4 ? digits : digits.substring(digits.length - 4);
  }

  String _groupDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}

/// A number controller that masks digits in the DISPLAY (each digit -> •) while
/// [obscure] is true, but keeps the real grouped value in [text] and preserves
/// the grouping spaces — so a hidden card number still reads `•••• •••• ••••
/// ••••` instead of a run of dots.
class _MaskedNumberController extends TextEditingController {
  bool obscure = true;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (!obscure) {
      return super.buildTextSpan(
          context: context, style: style, withComposing: withComposing);
    }
    final masked = text.replaceAllMapped(RegExp(r'\d'), (_) => '•');
    return TextSpan(style: style, text: masked);
  }
}

/// Groups the card number into blocks of 4 (up to 19 digits).
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 19 ? digits.substring(0, 19) : digits;
    final buf = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(capped[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formats expiry as MM/YY.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 4 ? digits.substring(0, 4) : digits;
    String text;
    if (capped.length <= 2) {
      text = capped;
    } else {
      text = '${capped.substring(0, 2)}/${capped.substring(2)}';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
