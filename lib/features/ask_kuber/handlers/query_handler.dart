import '../models/handler_result.dart';
import '../models/query_context.dart';

/// A single unit of query routing. The orchestrator invokes [tryHandle] on each
/// handler in priority order and uses the first non-null result.
///
/// Returning null means "not mine, fall through" - this mirrors the original
/// monolithic `_processQuery` if/else chain exactly, including cases where a
/// keyword matches but the inner guards don't (those must fall through to the
/// fallback, not get swallowed). Handlers do a cheap synchronous keyword guard
/// first and only `await` provider reads once a branch actually matches, so no
/// extra async work happens for queries they don't own.
abstract class QueryHandler {
  const QueryHandler();

  Future<HandlerResult?> tryHandle(QueryContext ctx);
}
