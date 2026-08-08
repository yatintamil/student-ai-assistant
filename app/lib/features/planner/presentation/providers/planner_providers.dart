import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/ai/ai_planner_service.dart';
import '../../../../core/services/ai/gemini_planner_service.dart';
import '../../data/repositories/planner_repository_impl.dart';
import '../../domain/repositories/planner_repository.dart';
import '../controllers/planner_controller.dart';
import '../states/planner_state.dart';

/// Provides the [FirebaseFirestore] client used by the planner feature.
///
/// This is the planner feature's sole reference to [FirebaseFirestore.instance].
final plannerFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provides the domain [PlannerRepository] implementation.
///
/// [PlannerRepositoryImpl] receives Firestore directly; there is no separate
/// data-source abstraction for the planner.
final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  final firestore = ref.watch(plannerFirestoreProvider);
  return PlannerRepositoryImpl(firestore);
});

/// Provides the [AiPlannerService] implementation.
///
/// This is the planner feature's sole reference to [GeminiPlannerService].
/// Override this provider in tests to inject a fake service.
final aiPlannerServiceProvider = Provider<AiPlannerService>((ref) {
  return GeminiPlannerService();
});

/// Provides the [PlannerController] as the source of planner state.
final plannerControllerProvider =
    NotifierProvider<PlannerController, PlannerState>(PlannerController.new);
