import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_assistant/presentation/pages/ai_chat_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/goals/domain/entities/goal_entity.dart';
import '../../features/goals/presentation/pages/goal_detail_page.dart';
import '../../features/goals/presentation/pages/goal_list_page.dart';
import '../../features/goals/presentation/providers/goal_providers.dart';
import '../../features/habits/presentation/pages/habit_list_page.dart';
import '../../features/journal/presentation/pages/journal_page.dart';
import '../../features/knowledge/presentation/pages/knowledge_page.dart';
import '../../features/navigation/presentation/pages/main_navigation_shell.dart';
import '../../features/planner/presentation/pages/today_plan_page.dart';
import '../../features/profile/presentation/pages/onboarding/welcome_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/tasks/presentation/pages/add_task_page.dart';
import '../../features/tasks/presentation/pages/task_list_page.dart';
import 'route_names.dart';

abstract final class AppRoutes {
  static final List<RouteBase> routes = <RouteBase>[
    GoRoute(
      path: RouteNames.calendar,
      builder: (context, state) => const CalendarPage(),
    ),
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const MainNavigationShell(),
    ),
    GoRoute(
      path: RouteNames.goals,
      builder: (context, state) => const GoalListPage(),
    ),
    GoRoute(
      path: '${RouteNames.goals}/:goalId',
      builder: (context, state) {
        final goalId = state.pathParameters['goalId'];
        // Goal detail page will be passed via route arguments or we need to fetch from provider
        // For now, return a placeholder that will load the goal
        return _GoalDetailLoader(goalId: goalId);
      },
    ),
    GoRoute(
      path: RouteNames.tasks,
      builder: (context, state) => const TaskListPage(),
    ),
    GoRoute(
      path: '${RouteNames.tasks}/add',
      builder: (context, state) => const AddTaskPage(),
    ),
    GoRoute(
      path: RouteNames.habits,
      builder: (context, state) => const HabitListPage(),
    ),
    GoRoute(
      path: RouteNames.plan,
      builder: (context, state) => const TodayPlanPage(),
    ),
    GoRoute(
      path: RouteNames.journal,
      builder: (context, state) => const JournalPage(),
    ),
    GoRoute(
      path: RouteNames.aiAssistant,
      builder: (context, state) => const AiChatPage(),
    ),
    GoRoute(
      path: RouteNames.knowledge,
      builder: (context, state) => const KnowledgePage(),
    ),
    GoRoute(
      path: RouteNames.settings,
      builder: (context, state) => const SettingsPage(),
    ),
  ];
}
/// Helper widget that loads a goal by ID and displays GoalDetailPage
class _GoalDetailLoader extends ConsumerWidget {
  const _GoalDetailLoader({this.goalId});

  final String? goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (goalId == null) {
      return const Scaffold(
        body: Center(child: Text('Invalid goal')),
      );
    }

    // Watch goals and find the one with matching ID
    final goalState = ref.watch(goalControllerProvider);
    final goal = goalState.goals.where((g) => g.id == goalId).firstOrNull;

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Goal Not Found')),
        body: const Center(child: Text('This goal could not be found.')),
      );
    }

    return GoalDetailPage(goal: goal);
  }
}
