import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/dashboard_state.dart';

/// Owns the dashboard's placeholder presentation state.
///
/// This controller follows the Riverpod 3 [Notifier] pattern: it has a
/// zero-argument constructor and resolves all dependencies inside [build] via
/// [Ref.read]. It intentionally contains no business logic, no Firestore
/// access, and no navigation code — it is a pure presentation-layer component.
///
/// The current implementation populates the state with placeholder data so
/// that the dashboard can be rendered and iterated on before a real data layer
/// is wired in.
class DashboardController extends Notifier<DashboardState> {
  /// Initialises the controller with placeholder dashboard data.
  @override
  DashboardState build() => DashboardState.initial();

}
