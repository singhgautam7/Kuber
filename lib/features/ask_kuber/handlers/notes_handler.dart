import '../../notes/data/notes_repository.dart';
import '../../notes/providers/notes_provider.dart';
import '../models/chip_action.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';
import 'thinking_steps.dart';

/// Kuber Notes intent (screen 1i): "show my notes", "what did I note this
/// month", "recent notes", "notes with numbers", "unconverted numbers".
/// Responds with a summary line plus up to three tappable recent-note pills.
class NotesHandler extends QueryHandler {
  const NotesHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    final mentionsNotes =
        lower.contains('note') || lower.contains('unconverted');
    if (!mentionsNotes) return null;

    final isQuery = lower.contains('show') ||
        lower.contains('what did i') ||
        lower.contains('recent') ||
        lower.contains('my note') ||
        lower.contains('unconverted') ||
        lower.contains('numbers');
    if (!isQuery) return null;

    final repo = ctx.read(notesRepositoryProvider);
    var notes = await repo.getAll();

    final monthScoped = lower.contains('month');
    if (monthScoped) {
      notes = notes
          .where((n) =>
              !n.updatedAt.isBefore(ctx.monthStart) &&
              n.updatedAt.isBefore(ctx.monthEnd))
          .toList();
    }
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    if (notes.isEmpty) {
      return HandlerResult(
        text: monthScoped
            ? 'You have no notes from this month. Open Kuber Notes from '
                'More to jot your first one.'
            : 'You have no notes yet. Open Kuber Notes from More to jot '
                'your first one.',
        followUps: const [
          NavChipAction(label: 'Open Kuber Notes', route: '/more/notes'),
        ],
      );
    }

    // Aggregate unconverted highlighted numbers across the notes.
    var aggregate = 0.0;
    var notesWithNumbers = 0;
    for (final n in notes) {
      final tokens = noteNumberTokens(n);
      if (tokens.isEmpty) continue;
      notesWithNumbers++;
      aggregate += tokens.fold(0.0, (s, t) => s + t.value);
    }

    final countLabel = notes.length == 1 ? '1 note' : '${notes.length} notes';
    final scopeLabel = monthScoped ? ' from this month' : '';
    final amountClause = notesWithNumbers == 0
        ? ''
        : ', with ${ctx.money(aggregate.abs())} across '
            '$notesWithNumbers unconverted '
            '${notesWithNumbers == 1 ? 'note' : 'notes'}';

    final recent = notes.take(3).toList();

    return HandlerResult(
      text: 'You have $countLabel$scopeLabel$amountClause. '
          'Tap a note below to open it.',
      thinking: ThinkingInfo(
        dateFilter: monthScoped ? 'This month' : 'All time',
        scanned: const ['Kuber Notes'],
        steps: [
          intentStep('notes summary', monthScoped ? 'this month' : 'all time'),
          const ThinkingStep('Scanned your **Kuber Notes**.'),
          resultStep(
              'Found **$countLabel**$scopeLabel$amountClause.'),
        ],
      ),
      followUps: [
        for (final n in recent)
          NavChipAction(
            label: n.title.isEmpty ? 'Untitled note' : n.title,
            route: '/notes/editor?id=${n.id}',
          ),
      ],
    );
  }
}
