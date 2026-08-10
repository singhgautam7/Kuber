import 'package:flutter/material.dart';

import '../../core/models/info_config.dart';

/// The four Kuber Cards info sheets, reusing the shared `KuberInfoBottomSheet`
/// pattern (as Ask Kuber / SMS Import / Notes do). English source; copy per
/// `info-sheets.md`. No em dashes, never imply PIN recovery is possible.

const aboutKuberCardsInfo = KuberInfoConfig(
  title: 'About Kuber Cards',
  description:
      'Kuber Cards keeps your payment cards safe on this device. Everything is '
      'encrypted, works offline, and never leaves your phone.',
  items: [
    KuberInfoItem(
      icon: Icons.lock_rounded,
      title: 'Encrypted at rest',
      description:
          'Your card details are encrypted on this device. Even a copied file '
          'is unreadable without your PIN.',
    ),
    KuberInfoItem(
      icon: Icons.wifi_off_rounded,
      title: 'Offline only',
      description:
          'Kuber Cards never syncs and never sends your cards anywhere. There '
          'is no cloud copy.',
    ),
    KuberInfoItem(
      icon: Icons.credit_card_off_rounded,
      title: 'No CVV stored',
      description:
          'We do not store your CVV, and we suggest you do not either. Same for '
          'OTPs and PINs.',
    ),
    KuberInfoItem(
      icon: Icons.pin_rounded,
      title: 'Locked by your PIN',
      description:
          'A 4 or 6 digit PIN protects your cards. Biometrics are a faster way '
          'to unlock, but the PIN is the master key.',
    ),
    KuberInfoItem(
      icon: Icons.warning_amber_rounded,
      title: 'No recovery',
      description:
          'If you forget your PIN, your cards cannot be recovered by anyone. '
          'That is the trade for real privacy.',
    ),
    KuberInfoItem(
      icon: Icons.backup_rounded,
      title: 'Portable with your PIN',
      description:
          'Your cards travel inside your Kuber backup and unlock on a new '
          'device with the same PIN.',
    ),
  ],
);

const aboutCustomFieldsInfo = KuberInfoConfig(
  title: 'About custom fields',
  description:
      'Custom fields let you store anything a card needs that is not a standard '
      'field, like a reward tier, a billing zip, or a support number.',
  items: [
    KuberInfoItem(
      icon: Icons.list_alt_rounded,
      title: 'Anything as a label and value',
      description:
          'Add as many label and value pairs as you like. They are encrypted '
          'just like the rest of the card.',
    ),
    KuberInfoItem(
      icon: Icons.shield_outlined,
      title: 'Think before storing secrets',
      description:
          'Codes like CVV, PIN, and OTP are safest kept out of any app. If you '
          'add one, we will gently check with you first.',
    ),
    KuberInfoItem(
      icon: Icons.visibility_off_rounded,
      title: 'Sensitive values stay hidden',
      description:
          'Fields you label like a CVV or PIN are masked in the card view and '
          'reveal only when you tap to show them.',
    ),
  ],
);

const howEncryptionWorksInfo = KuberInfoConfig(
  title: 'How encryption works',
  description:
      'Here is the plain-English version of what happens when you save a card.',
  items: [
    KuberInfoItem(
      icon: Icons.password_rounded,
      title: 'Your PIN makes the key',
      description:
          'Your PIN is turned into an encryption key on this device. The PIN '
          'itself is never stored.',
    ),
    KuberInfoItem(
      icon: Icons.lock_rounded,
      title: 'Cards are locked with that key',
      description:
          'Every card is encrypted with the key before it is written to '
          'storage. Without the key it is just noise.',
    ),
    KuberInfoItem(
      icon: Icons.fingerprint_rounded,
      title: 'Biometrics unlock, they do not replace',
      description:
          'Fingerprint or face unlock is a convenient way to reach the key. '
          'Your PIN still works and stays in charge.',
    ),
    KuberInfoItem(
      icon: Icons.phonelink_lock_rounded,
      title: 'It stays on this device',
      description:
          'Encryption and decryption happen only on your phone. Nothing is '
          'sent to a server, ever.',
    ),
    KuberInfoItem(
      icon: Icons.warning_amber_rounded,
      title: 'No key, no recovery',
      description:
          'Because only your PIN can make the key, no one can unlock your cards '
          'for you if you forget it.',
    ),
  ],
);

const whatWeDontStoreInfo = KuberInfoConfig(
  title: 'What we do not store',
  description:
      'Some things are safer when they live only in your head. Kuber Cards '
      'never keeps these.',
  items: [
    KuberInfoItem(
      icon: Icons.credit_card_off_rounded,
      title: 'Your CVV',
      description:
          'The 3 or 4 digit code on your card is never stored. Type it fresh '
          'each time you pay.',
    ),
    KuberInfoItem(
      icon: Icons.pin_rounded,
      title: 'Your card PIN',
      description:
          'The PIN you enter at an ATM or terminal is not kept here.',
    ),
    KuberInfoItem(
      icon: Icons.sms_failed_rounded,
      title: 'OTPs',
      description:
          'One time passwords are meant to be used once. We never store them.',
    ),
    KuberInfoItem(
      icon: Icons.key_off_rounded,
      title: 'Passwords',
      description:
          'Kuber Cards is for card details, not for passwords or login secrets.',
    ),
    KuberInfoItem(
      icon: Icons.cloud_off_rounded,
      title: 'A cloud copy',
      description:
          'There is no server copy of your cards. What is on your device is all '
          'there is.',
    ),
  ],
);
