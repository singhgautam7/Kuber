/// The single, unified time-to-live for every story, of every type. A story is
/// shown in the ring/archive for at most this long after it was generated or
/// last updated. There is intentionally no per-type TTL.
const Duration kStoryTtl = Duration(hours: 48);

/// How long expired rows are kept as tombstones before the hard-delete sweep.
/// Must be >= the longest cadence window (20 days, see story_generation_service)
/// so the cadence dedup queries still see recently-expired stories.
const Duration kStoryTombstoneRetention = Duration(days: 30);
