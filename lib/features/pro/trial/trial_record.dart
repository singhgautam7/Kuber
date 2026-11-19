/// The signed trial record kept in the entitlement row, Block Store and every
/// JSON backup: `{v, id, start, sig}`. `sig` is a base64url HMAC-SHA256 over
/// `"v|id|start"` (see trial_signer.dart).
class TrialRecord {
  final int v;
  final String id;

  /// Start, epoch ms UTC.
  final int startMs;
  final String sig;

  const TrialRecord({required this.v, required this.id, required this.startMs, required this.sig});

  DateTime get start => DateTime.fromMillisecondsSinceEpoch(startMs, isUtc: true);

  String get payload => '$v|$id|$startMs';

  Map<String, dynamic> toJson() => {'v': v, 'id': id, 'start': startMs, 'sig': sig};

  /// Null when [raw] is not a well-formed record (callers treat that as an
  /// invalid record, i.e. "trial used").
  static TrialRecord? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final v = raw['v'];
    final id = raw['id'];
    final start = raw['start'];
    final sig = raw['sig'];
    if (v is! int || id is! String || start is! int || sig is! String || id.isEmpty) return null;
    return TrialRecord(v: v, id: id, startMs: start, sig: sig);
  }
}
