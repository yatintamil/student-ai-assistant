import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/dashboard_controller.dart';
import '../states/dashboard_state.dart';

/// Provides the [DashboardController] as the single source of truth for
/// dashboard presentation state.
///
/// This is a [NotifierProvider] that exposes [DashboardController] — a
/// [Notifier<DashboardState>] — to the presentation layer. The controller
/// follows the Riverpod 3 [Notifier] pattern with a zero-argument constructor.
final dashboardControllerProvider =
    NotifierProvider<DashboardController, DashboardState>(
      DashboardController.new,
    );
