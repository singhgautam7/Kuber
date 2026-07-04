/// Static content for the Kuber Notes onboarding demo note.
///
/// Created once per install, gated by the persisted
/// `notes_onboarding_seen` flag. If the user deletes the note it is never
/// recreated; the flag alone is authoritative.
library;

const String kNotesDemoTitle = 'Welcome to Kuber Notes';

/// Quill Delta JSON for the demo note body (screen 1e). Numeric tokens carry
/// the number-highlight attribute up front so the note renders highlighted
/// even before the first editor pass runs.
const String kNotesOnboardingDemoContent =
    '[{"insert":"Kuber Notes is a place to jot down expenses, do quick math, '
    'and turn them into real transactions.\\n\\n'
    'Here\'s a simple grocery list:\\nMilk "},'
    '{"insert":"60","attributes":{"kuber-num":"pos"}},'
    '{"insert":"\\nBread "},'
    '{"insert":"45","attributes":{"kuber-num":"pos"}},'
    '{"insert":"\\nEggs "},'
    '{"insert":"90","attributes":{"kuber-num":"pos"}},'
    '{"insert":"\\nVegetables "},'
    '{"insert":"220","attributes":{"kuber-num":"pos"}},'
    '{"insert":"\\n"},'
    '{"insert":"-30","attributes":{"kuber-num":"neg"}},'
    '{"insert":" (discount)\\n\\n'
    'Type \\"total\\" or \\"=\\" on a new line below to see the magic.\\n\\n'
    'You can also tap any highlighted number for quick actions:\\n"},'
    '{"insert":"\\u20b9500","attributes":{"kuber-num":"pos"}},'
    '{"insert":"\\nTap it to add as a transaction, recurring, investment, '
    'and more.\\n\\n'
    'Quick inline math also works. Write an expression before = and Kuber '
    'solves it with BODMAS:\\nEggs "},'
    '{"insert":"7","attributes":{"kuber-num":"pos"}},'
    '{"insert":" * "},'
    '{"insert":"10","attributes":{"kuber-num":"pos"}},'
    '{"insert":" =\\n"}]';
