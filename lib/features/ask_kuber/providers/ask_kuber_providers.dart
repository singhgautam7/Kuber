import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../services/ask_kuber_repository.dart';
import '../services/query_orchestrator.dart';

/// Chat-history persistence for Ask Kuber.
final askKuberRepositoryProvider = Provider<AskKuberRepository>((ref) {
  return AskKuberRepository(ref.watch(isarProvider));
});

/// The handler chain. Stateless, so a single shared instance is fine.
final queryOrchestratorProvider = Provider<QueryOrchestrator>((ref) {
  return QueryOrchestrator.standard();
});
