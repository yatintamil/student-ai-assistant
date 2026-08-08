import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../ai_assistant/presentation/pages/ai_chat_page.dart';
import '../../../ai_assistant/presentation/providers/ai_chat_providers.dart';
import '../../../../core/services/life_context/life_context_providers.dart';
import '../../../goals/presentation/providers/goal_providers.dart';
import '../../../habits/domain/entities/habit_entity.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../habits/presentation/states/habit_state.dart';
import '../../../journal/presentation/providers/journal_providers.dart';
import '../../../planner/presentation/providers/planner_providers.dart';
import '../../../planner/presentation/widgets/current_session_card.dart';
import '../../../tasks/domain/entities/task_entity.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/states/task_state.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../calendar/presentation/providers/calendar_providers.dart';
import '../states/dashboard_state.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/greeting_card.dart';
import '../widgets/habits_card.dart';
import '../widgets/projects_card.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/today_progress_card.dart';
import '../widgets/today_tasks_card.dart';
import '../widgets/top_recommendation_card.dart';

/// The root page of the dashboard feature.
///
/// Watches [taskControllerProvider], [habitControllerProvider], and
/// [plannerControllerProvider] for the authenticated user's real data.
/// - Tasks populate [TodayTasksCard] and [TodayProgressCard].
/// - Habits populate [HabitsCard].
/// - The current / next planner session populates [CurrentSessionCard].
class DashboardPage extends ConsumerStatefulWidget {
  /// Creates the dashboard page.
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAll();
    });
  }

  void _loadAll() {
    final uid = _uid;
    if (uid == null) return;
    ref.read(goalControllerProvider.notifier).loadGoals(uid);
    ref.read(journalControllerProvider.notifier).loadJournalEntries(uid);
    ref.read(calendarControllerProvider.notifier).loadEvents(uid, start: DateUtils.dateOnly(DateTime.now()), end: DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 1)));
    _loadTasks();
    _loadHabits();
    _refreshPlan();
  }

  String? get _uid => ref.read(authControllerProvider).user?.id;

  // ---------------------------------------------------------------------------
  // Loaders
  // ---------------------------------------------------------------------------

  void _loadTasks() {
    final uid = _uid;
    if (uid == null) return;
    ref.read(taskControllerProvider.notifier).loadTasks(uid);
  }

  void _loadHabits() {
    final uid = _uid;
    if (uid == null) return;
    ref.read(habitControllerProvider.notifier).loadHabits(uid);
  }

  void _refreshPlan() {
    final uid = _uid;
    if (uid == null) return;
    ref.read(plannerControllerProvider.notifier).refreshPlan(uid);
  }

  // ---------------------------------------------------------------------------
  // Toggles
  // ---------------------------------------------------------------------------

  Future<void> _toggleTask(TaskEntity task) async {
    final uid = _uid;
    if (uid == null) return;
    await ref.read(taskControllerProvider.notifier).toggleCompleted(uid, task);
  }

  Future<void> _toggleHabit(HabitEntity habit) async {
    final uid = _uid;
    if (uid == null) return;
    await ref
        .read(habitControllerProvider.notifier)
        .toggleCompletedToday(uid, habit);
  }

  Future<void> _markSessionCompleted() async {
    final uid = _uid;
    if (uid == null) return;
    final current =
        ref.read(plannerControllerProvider).currentSession;
    if (current == null) return;
    await ref
        .read(plannerControllerProvider.notifier)
        .markCompleted(uid, current.id);
  }

  void _askAiAboutRecommendation(String recommendation) {
    ref.read(aiChatControllerProvider.notifier).sendMessage(
          'Why is this the best thing for me to do right now: "$recommendation"?',
          lifeContext: ref.read(lifeContextProvider).toPromptContext(),
        );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AiChatPage(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardControllerProvider);
    final lifeContext = ref.watch(lifeContextProvider);
    final taskState = ref.watch(taskControllerProvider);
    final habitState = ref.watch(habitControllerProvider);
    final plannerState = ref.watch(plannerControllerProvider);

    final aiInsight = plannerState.reasoning?.isNotEmpty == true
        ? plannerState.reasoning!
        : '';

    final topRecommendation = lifeContext.topRecommendation;

    final goalProjects = lifeContext.activeGoals
        .take(4)
        .map(
          (g) => DashboardProject(
            name: g.title,
            tag: g.category.name,
            progress: g.progress,
          ),
        )
        .toList();

    // Task progress derived from real data.
    final tasks = taskState.tasks;
    final completedTasks =
        tasks.where((t) => t.status == TaskStatus.completed).length;
    final taskProgress =
        tasks.isEmpty ? 0.0 : completedTasks / tasks.length;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth >= 600 ? 32.0 : 20.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24,
                  ),
                  children: <Widget>[
                    GreetingCard(displayName: lifeContext.profile?.displayName),
                    const SizedBox(height: 16),
                    TopRecommendationCard(
                      recommendation: topRecommendation,
                      onAskAi: () => _askAiAboutRecommendation(topRecommendation),
                    ),
                    const SizedBox(height: 16),

                    // ── Current / Next Session ─────────────────────────────
                    CurrentSessionCard(
                      currentSession: plannerState.currentSession,
                      nextSession: plannerState.nextSession,
                      onMarkCompleted: _markSessionCompleted,
                    ),
                    const SizedBox(height: 12),

                    TodayProgressCard(progress: taskProgress),
                    const SizedBox(height: 12),
                    _AvailableTimeCard(minutes: lifeContext.toPlannerContext().availableMinutes),
                    const SizedBox(height: 12),

                    // ── Tasks ────────────────────────────────────────────────
                    _buildTasksSection(taskState),
                    const SizedBox(height: 12),

                    // ── Habits ───────────────────────────────────────────────
                    _buildHabitsSection(habitState),
                    const SizedBox(height: 12),

                    ProjectsCard(
                      projects: goalProjects.isNotEmpty
                          ? goalProjects
                          : dashState.projects,
                    ),
                    const SizedBox(height: 12),
                    const QuickActionsCard(),
                    const SizedBox(height: 12),
                    AiInsightCard(insight: aiInsight),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section builders
  // ---------------------------------------------------------------------------

  Widget _buildTasksSection(TaskState taskState) {
    if (taskState.isLoading) return const _LoadingCard();
    if (taskState.errorMessage != null) {
      return _ErrorCard(
        message: taskState.errorMessage!,
        onRetry: _loadTasks,
      );
    }
    return TodayTasksCard(tasks: taskState.tasks, onToggle: _toggleTask);
  }

  Widget _buildHabitsSection(HabitState habitState) {
    if (habitState.isLoading) return const _LoadingCard();
    if (habitState.errorMessage != null) {
      return _ErrorCard(
        message: habitState.errorMessage!,
        onRetry: _loadHabits,
      );
    }
    return HabitsCard(habits: habitState.habits, onToggle: _toggleHabit);
  }
}

class _AvailableTimeCard extends StatelessWidget { const _AvailableTimeCard({required this.minutes}); final int minutes; @override Widget build(BuildContext context) { final hours = minutes ~/ 60; final remaining = minutes % 60; return Card(child: ListTile(leading: const Icon(Icons.schedule), title: Text('You have $hours h $remaining min free today'), subtitle: const Text('Outside fixed calendar commitments.'))); } }

// ---------------------------------------------------------------------------
// Shared inline loading / error cards
// ---------------------------------------------------------------------------

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Icon(Icons.error_outline, size: 36, color: cs.error),
            const SizedBox(height: 8),
            Text(
              message,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
