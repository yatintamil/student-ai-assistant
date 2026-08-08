import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/life_context/life_context_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../../habits/presentation/providers/habit_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../providers/planner_providers.dart';
import '../states/planner_state.dart';
import '../widgets/empty_plan_widget.dart';
import '../widgets/session_tile.dart';

/// Displays today's generated plan as a vertical timeline.
///
/// App bar actions:
///   - AI sparkle button → [_AiActionsSheet] bottom sheet with three AI modes.
///   - Deterministic "Generate" button when the plan is empty.
///
/// States:
///   - Loading  → [CircularProgressIndicator] centred on screen.
///   - Error    → error message + Retry button.
///   - Empty    → [EmptyPlanWidget] with "Generate" and "AI Generate" buttons.
///   - Loaded   → scrollable [SessionTile] timeline.
class TodayPlanPage extends ConsumerStatefulWidget {
  /// Creates [TodayPlanPage].
  const TodayPlanPage({super.key});

  @override
  ConsumerState<TodayPlanPage> createState() => _TodayPlanPageState();
}

class _TodayPlanPageState extends ConsumerState<TodayPlanPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String? get _uid => ref.read(authControllerProvider).user?.id;

  void _refresh() {
    final uid = _uid;
    if (uid == null) return;
    ref.read(plannerControllerProvider.notifier).refreshPlan(uid);
  }

  /// Deterministic plan — no AI.
  Future<void> _generateDeterministic() async {
    final uid = _uid;
    if (uid == null) return;
    final profile = ref.read(profileControllerProvider).profile;
    if (profile == null) { _noProfileSnack(); return; }
    await ref.read(plannerControllerProvider.notifier).generateTodayPlan(
          uid: uid,
          profile: profile,
          tasks: ref.read(taskControllerProvider).tasks,
          habits: ref.read(habitControllerProvider).habits,
          busyTimeBlocks: ref.read(lifeContextProvider).busyTimeBlocks,
        );
  }

  /// AI full regeneration.
  Future<void> _regenerateWithAi() async {
    final uid = _uid;
    if (uid == null) return;
    final lifeContext = ref.read(lifeContextProvider);
    if (lifeContext.profile == null) {
      _noProfileSnack();
      return;
    }
    await ref.read(plannerControllerProvider.notifier).regeneratePlanFromContext(
          uid: uid,
          lifeContext: lifeContext,
        );
  }

  /// AI simplify.
  Future<void> _simplifyWithAi() async {
    final uid = _uid;
    if (uid == null) return;
    final lifeContext = ref.read(lifeContextProvider);
    if (lifeContext.profile == null) {
      _noProfileSnack();
      return;
    }
    await ref.read(plannerControllerProvider.notifier).simplifyPlanFromContext(
          uid: uid,
          lifeContext: lifeContext,
        );
  }

  /// AI fit-into-time — prompts for minutes first.
  Future<void> _fitIntoTime() async {
    final minutes = await _promptForMinutes();
    if (minutes == null) return;
    final uid = _uid;
    if (uid == null) return;
    final lifeContext = ref.read(lifeContextProvider);
    if (lifeContext.profile == null) {
      _noProfileSnack();
      return;
    }
    await ref
        .read(plannerControllerProvider.notifier)
        .fitIntoAvailableTimeFromContext(
          uid: uid,
          lifeContext: lifeContext,
          availableMinutes: minutes,
        );
  }

  Future<void> _markCompleted(String sessionId) async {
    final uid = _uid;
    if (uid == null) return;
    await ref
        .read(plannerControllerProvider.notifier)
        .markCompleted(uid, sessionId);
  }

  void _noProfileSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complete your profile to generate a plan.'),
      ),
    );
  }

  /// Shows a bottom sheet with the three AI actions.
  void _showAiSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => _AiActionsSheet(
        onRegenerate: () { Navigator.pop(ctx); _regenerateWithAi(); },
        onSimplify: () { Navigator.pop(ctx); _simplifyWithAi(); },
        onFitIntoTime: () { Navigator.pop(ctx); _fitIntoTime(); },
      ),
    );
  }

  /// Prompts the user for a number of available minutes.
  Future<int?> _promptForMinutes() async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Available time'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Minutes available',
            suffixText: 'min',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              if (v != null && v > 0) Navigator.pop(ctx, v);
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final plannerState = ref.watch(plannerControllerProvider);
    final cs = Theme.of(context).colorScheme;
    final isLoading = plannerState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Plan"),
        actions: <Widget>[
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            // AI actions button (only meaningful once a plan exists or tasks are loaded)
            IconButton(
              onPressed: _showAiSheet,
              icon: const Icon(Icons.auto_awesome_outlined),
              tooltip: 'AI actions',
            ),
            // Deterministic generate / regenerate
            TextButton(
              onPressed: _generateDeterministic,
              child: Text(
                plannerState.sessions.isEmpty ? 'Generate' : 'Regenerate',
              ),
            ),
          ],
        ],
      ),
      body: _buildBody(plannerState, cs),
    );
  }

  Widget _buildBody(PlannerState plannerState, ColorScheme cs) {
    // Loading
    if (plannerState.isLoading) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    // Error
    if (plannerState.errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.error_outline, size: 48, color: cs.error),
              const SizedBox(height: 16),
              Text(
                plannerState.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (plannerState.sessions.isEmpty) {
      return _EmptyBody(
        onGenerateDeterministic: _generateDeterministic,
        onGenerateWithAi: _regenerateWithAi,
      );
    }

    // Loaded
    final sessions = plannerState.sessions;
    final busyBlocks = ref.watch(lifeContextProvider).busyTimeBlocks;
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 600 ? 32.0 : 20.0;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: 16,
              ),
              itemCount: sessions.length + (busyBlocks.isEmpty ? 0 : 1),
              itemBuilder: (context, index) {
                if (index == 0 && busyBlocks.isNotEmpty) {
                  return _BusyBlocksCard(blocks: busyBlocks);
                }
                final sessionIndex = index - (busyBlocks.isEmpty ? 0 : 1);
                return SessionTile(
                  session: sessions[sessionIndex],
                  isFirst: sessionIndex == 0,
                  isLast: sessionIndex == sessions.length - 1,
                  onMarkCompleted: () => _markCompleted(sessions[sessionIndex].id),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _BusyBlocksCard extends StatelessWidget {
  const _BusyBlocksCard({required this.blocks});
  final List<dynamic> blocks;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Fixed calendar commitments'), const SizedBox(height: 6), ...blocks.map((block) => Text('${TimeOfDay.fromDateTime(block.startTime).format(context)}–${TimeOfDay.fromDateTime(block.endTime).format(context)}  ${block.title}'))])));
}

// ---------------------------------------------------------------------------
// Empty body — shows both generate options
// ---------------------------------------------------------------------------

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({
    required this.onGenerateDeterministic,
    required this.onGenerateWithAi,
  });

  final VoidCallback onGenerateDeterministic;
  final VoidCallback onGenerateWithAi;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.calendar_today_outlined,
              size: 72,
              color: cs.onSurfaceVariant.withAlpha(100),
            ),
            const SizedBox(height: 24),
            Text(
              'No plan for today',
              style: tt.titleMedium?.copyWith(color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a schedule from your tasks and habits.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onGenerateWithAi,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Generate with AI'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onGenerateDeterministic,
              icon: const Icon(Icons.playlist_add_outlined),
              label: const Text('Generate (basic)'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AI actions bottom sheet
// ---------------------------------------------------------------------------

class _AiActionsSheet extends StatelessWidget {
  const _AiActionsSheet({
    required this.onRegenerate,
    required this.onSimplify,
    required this.onFitIntoTime,
  });

  final VoidCallback onRegenerate;
  final VoidCallback onSimplify;
  final VoidCallback onFitIntoTime;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.auto_awesome_outlined,
                    size: 20, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'AI Plan Actions',
                  style: tt.titleMedium?.copyWith(color: cs.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SheetTile(
              icon: Icons.refresh_outlined,
              title: 'Regenerate Plan',
              subtitle: 'Build a fresh AI schedule from all pending tasks and habits.',
              onTap: onRegenerate,
            ),
            _SheetTile(
              icon: Icons.compress_outlined,
              title: 'Simplify Plan',
              subtitle: 'Merge and trim the current plan to reduce clutter.',
              onTap: onSimplify,
            ),
            _SheetTile(
              icon: Icons.timer_outlined,
              title: 'Fit Into Available Time',
              subtitle: 'Compress the most important items into the time you have.',
              onTap: onFitIntoTime,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
