import 'package:flutter/material.dart';
import '../../../core/theme/kuber_style.dart';
import 'settings_choice_sheet.dart';

/// Pass this to `SettingsChoiceSheet<KuberStyle>(choices: ...)`.
List<SettingsChoice<KuberStyle>> designLanguageChoices(BuildContext context) => [
      const SettingsChoice(
        value: KuberStyle.signature,
        label: 'Kuber Signature',
        subtitle: 'Crisp 8dp corners, compact.',
        icon: Icons.bolt_rounded,
      ),
      const SettingsChoice(
        value: KuberStyle.m3Expressive,
        label: 'Material 3 Expressive',
        subtitle: 'Pill shapes, springy motion.',
        icon: Icons.auto_awesome_rounded,
      ),
    ];
