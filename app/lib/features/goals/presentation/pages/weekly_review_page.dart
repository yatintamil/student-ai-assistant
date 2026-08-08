import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/gemini_config.dart';
import '../../../../core/services/life_context/life_context_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../providers/goal_providers.dart';

/// Weekly goal review page with AI-generated insights and recommendations.
/// 
/// Displays:
/// - Overall goal progress statistics
/// - AI-generated weekly summary and insights
/// - Goal-by-goal breakdown with progress
/// - Actionable recommendations for the upcoming week
class WeeklyReviewPage extends ConsumerStatefulWidget {
  const WeeklyReviewPage({super.key});

  @override
  ConsumerState<WeeklyReviewPage> createState() => _WeeklyReviewPageState();
}

class _WeeklyReviewPageState extends ConsumerState<WeeklyReviewPage> {
  bool _isGeneratingInsights = false;
  String? _aiInsights;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateWeeklyInsights();
    });
  }

  Future<void> _generateWeeklyInsights() async {
    setState(() {
      _isGeneratingInsights = true;
      _errorMessage = null;
    });

    try {
      final lifeContext = ref.read(lifeContextProvider);
      final goals = lifeContext.activeGoals;
      final tasks = ref.read(lifeContextProvider).pendingTasks;
      final profile = lifeContext.profile;

      if (!GeminiConfig.isConfigured) {
        setState(() {
          _errorMessage = 'Gemini API key not configured. Weekly insights unavailable.';
          _isGeneratingInsights = false;
        });
        return;
      }

      // Build context for AI
      final prompt = '''
You are an AI Chief of Staff conducting a weekly goal alignment review.

USER PROFILE:
- Name: ${profile?.displayName ?? 'User'}
- Focus Goal: ${profile?.focusGoal ?? 'Not set'}

GOAL SUMMARY:
${goals.isEmpty ? 'No goals defined yet.' : goals.map((g) {
        final progressPct = (g.progress * 100).toInt();
        return '- [${g.level.name.toUpperCase()}] ${g.title}: $progressPct% complete (${g.category.name})';
      }).join('\n')}

TASK OVERVIEW:
- Total pending tasks: ${tasks.length}
- Tasks linked to goals: ${tasks.where((t) => t.goalId != null).length}
- Tasks without goals: ${tasks.where((t) => t.goalId == null).length}

Generate a weekly review that includes:

1. **Executive Summary** (2-3 sentences)
   - Overall progress this week
   - Key achievements
   - Main challenge or blocker

2. **Goal-Level Insights** (bullet points for each active goal)
   - What's working well
   - What needs attention
   - Recommended next action

3. **Strategic Recommendations** (3-5 action items)
   - Priority adjustments for next week
   - New goals to consider
   - Habits or routines to establish

4. **Motivational Close** (1-2 sentences)
   - Recognition of effort
   - Encouragement aligned with their focus goal

Keep the tone professional, empowering, and actionable. Format with markdown for readability.
''';

      final model = GeminiConfig.createModel();
      final response = await model.generateContent([Content.text(prompt)]);
      final insights = response.text ?? 'Unable to generate insights at this time.';

      setState(() {
        _aiInsights = insights;
        _isGeneratingInsights = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate insights: ${e.toString()}';
        _isGeneratingInsights = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lifeContext = ref.watch(lifeContextProvider);
    final goals = lifeContext.activeGoals;
    
    final totalGoals = goals.length;
    final completedGoals = goals.where((g) => g.isCompleted).length;
    final avgProgress = goals.isEmpty
        ? 0.0
        : goals.fold<double>(0, (sum, g) => sum + g.progress) / totalGoals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Goal Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isGeneratingInsights ? null : _generateWeeklyInsights,
            tooltip: 'Regenerate Insights',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics overview card
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Weekly Alignment Summary',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatColumn(
                          icon: Icons.flag,
                          label: 'Active Goals',
                          value: totalGoals.toString(),
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        _StatColumn(
                          icon: Icons.check_circle,
                          label: 'Completed',
                          value: completedGoals.toString(),
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        _StatColumn(
                          icon: Icons.trending_up,
                          label: 'Avg Progress',
                          value: '${(avgProgress * 100).toInt()}%',
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top recommendation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Top Recommendation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lifeContext.topRecommendation,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // AI Insights section
            Text(
              'AI-Generated Insights',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            if (_isGeneratingInsights)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Analyzing your goals and generating insights...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_errorMessage != null)
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_aiInsights != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _aiInsights!,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No insights generated yet. Tap refresh to generate.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Goal breakdown
            Text(
              'Goal Breakdown',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            if (goals.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No goals defined yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...goals.map(
                (goal) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: goal.progress,
                            strokeWidth: 4,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            color: goal.progress >= 0.7
                                ? Colors.green
                                : goal.progress >= 0.3
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                        Text(
                          '${(goal.progress * 100).toInt()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      goal.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: goal.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(
                                goal.level.name.toUpperCase(),
                                style: const TextStyle(fontSize: 10),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            Chip(
                              label: Text(
                                goal.category.name.toUpperCase(),
                                style: const TextStyle(fontSize: 10),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Icon(
                      goal.isCompleted
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: goal.isCompleted
                          ? Colors.green
                          : theme.colorScheme.outline,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
