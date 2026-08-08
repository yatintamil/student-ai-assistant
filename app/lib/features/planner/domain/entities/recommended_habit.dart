import 'package:equatable/equatable.dart';

/// Why a habit is being recommended.
enum RecommendationReason {
  /// User's current habits conflict with their goals.
  conflictsWithGoals,

  /// Health and wellness improvement.
  healthOptimization,

  /// Productivity enhancement.
  productivityBoost,

  /// Sleep quality improvement.
  sleepQuality,

  /// Energy management.
  energyManagement,

  /// Focus and concentration.
  focusImprovement,

  /// General well-being.
  generalWellness,
}

/// A recommended habit improvement.
///
/// Used to suggest healthy habits when current habits conflict with user goals
/// or when the AI identifies opportunities for improvement.
class RecommendedHabit extends Equatable {
  /// Creates a recommended habit.
  const RecommendedHabit({
    required this.title,
    required this.description,
    required this.reason,
    required this.currentBehavior,
    required this.suggestedBehavior,
    required this.expectedBenefit,
    required this.priority,
    this.preferredTime,
    this.minimumDurationMinutes,
  });

  /// Title of the recommended habit.
  final String title;

  /// Detailed description of the habit.
  final String description;

  /// Why this habit is being recommended.
  final RecommendationReason reason;

  /// What the user currently does (or doesn't do).
  /// Example: "Wake up at 9 AM, no exercise routine"
  final String currentBehavior;

  /// What the AI suggests instead.
  /// Example: "Wake up at 7 AM, 30-minute morning exercise"
  final String suggestedBehavior;

  /// Expected benefit if adopted.
  /// Example: "Improved focus for morning deep work sessions, better sleep quality"
  final String expectedBenefit;

  /// Priority of this recommendation (1 = highest, 10 = lowest).
  final int priority;

  /// Suggested time to perform this habit.
  final String? preferredTime;

  /// Minimum duration in minutes.
  final int? minimumDurationMinutes;

  /// Whether this is a high-priority recommendation.
  bool get isHighPriority => priority <= 3;

  @override
  List<Object?> get props => [
        title,
        description,
        reason,
        currentBehavior,
        suggestedBehavior,
        expectedBenefit,
        priority,
        preferredTime,
        minimumDurationMinutes,
      ];
}

/// Pre-defined recommended habits that the AI can suggest.
class RecommendedHabits {
  RecommendedHabits._();

  /// Early wake-up habit.
  static RecommendedHabit earlyWakeUp({
    required String currentWakeTime,
    required String suggestedWakeTime,
  }) {
    return RecommendedHabit(
      title: 'Wake Up Earlier',
      description: 'Adjust your wake-up time to align with your productivity goals',
      reason: RecommendationReason.productivityBoost,
      currentBehavior: 'Currently waking up at $currentWakeTime',
      suggestedBehavior: 'Wake up at $suggestedWakeTime',
      expectedBenefit: 'More time for deep work when your mind is fresh, better alignment with study goals',
      priority: 2,
      preferredTime: suggestedWakeTime,
    );
  }

  /// Exercise habit.
  static RecommendedHabit exercise({
    required String preferredTime,
  }) {
    return RecommendedHabit(
      title: 'Daily Exercise',
      description: 'Physical activity to boost energy and focus',
      reason: RecommendationReason.energyManagement,
      currentBehavior: 'No regular exercise routine',
      suggestedBehavior: 'Add 30-45 minutes of exercise',
      expectedBenefit: 'Increased energy levels, improved focus, better sleep quality',
      priority: 1,
      preferredTime: preferredTime,
      minimumDurationMinutes: 30,
    );
  }

  /// Reading habit.
  static RecommendedHabit reading() {
    return const RecommendedHabit(
      title: 'Daily Reading',
      description: 'Read to expand knowledge and improve focus',
      reason: RecommendationReason.focusImprovement,
      currentBehavior: 'No regular reading habit',
      suggestedBehavior: 'Read for 20-30 minutes daily',
      expectedBenefit: 'Enhanced concentration, expanded knowledge, stress reduction',
      priority: 3,
      preferredTime: '21:00',
      minimumDurationMinutes: 20,
    );
  }

  /// Meditation habit.
  static RecommendedHabit meditation() {
    return const RecommendedHabit(
      title: 'Meditation',
      description: 'Mindfulness practice for mental clarity',
      reason: RecommendationReason.focusImprovement,
      currentBehavior: 'No meditation practice',
      suggestedBehavior: 'Meditate for 10-15 minutes daily',
      expectedBenefit: 'Reduced stress, improved focus, better emotional regulation',
      priority: 2,
      preferredTime: '07:30',
      minimumDurationMinutes: 10,
    );
  }

  /// Better sleep schedule.
  static RecommendedHabit betterSleep({
    required String currentSleepTime,
    required String suggestedSleepTime,
    required int currentSleepHours,
  }) {
    return RecommendedHabit(
      title: 'Optimize Sleep Schedule',
      description: 'Adjust sleep time for better rest and recovery',
      reason: RecommendationReason.sleepQuality,
      currentBehavior: 'Sleeping at $currentSleepTime ($currentSleepHours hours)',
      suggestedBehavior: 'Sleep at $suggestedSleepTime (7-8 hours)',
      expectedBenefit: 'Better energy levels, improved cognitive function, better health',
      priority: 1,
      preferredTime: suggestedSleepTime,
    );
  }

  /// Healthy breakfast habit.
  static RecommendedHabit healthyBreakfast() {
    return const RecommendedHabit(
      title: 'Healthy Breakfast',
      description: 'Nutritious morning meal to fuel your day',
      reason: RecommendationReason.energyManagement,
      currentBehavior: 'Irregular or skipped breakfast',
      suggestedBehavior: 'Eat a balanced breakfast daily',
      expectedBenefit: 'Sustained energy, improved concentration, better metabolism',
      priority: 2,
      preferredTime: '08:00',
      minimumDurationMinutes: 15,
    );
  }

  /// Hydration habit.
  static RecommendedHabit hydration() {
    return const RecommendedHabit(
      title: 'Regular Hydration',
      description: 'Drink water throughout the day',
      reason: RecommendationReason.generalWellness,
      currentBehavior: 'Irregular water intake',
      suggestedBehavior: 'Drink water every 1-2 hours',
      expectedBenefit: 'Better focus, improved energy, enhanced cognitive performance',
      priority: 3,
    );
  }

  /// Stretching habit.
  static RecommendedHabit stretching() {
    return const RecommendedHabit(
      title: 'Stretching Breaks',
      description: 'Regular stretching to reduce physical tension',
      reason: RecommendationReason.generalWellness,
      currentBehavior: 'No regular stretching routine',
      suggestedBehavior: 'Stretch for 5-10 minutes between work blocks',
      expectedBenefit: 'Reduced muscle tension, improved circulation, better posture',
      priority: 4,
      minimumDurationMinutes: 5,
    );
  }

  /// Walking habit.
  static RecommendedHabit walking() {
    return const RecommendedHabit(
      title: 'Daily Walk',
      description: 'Light walking for physical and mental health',
      reason: RecommendationReason.generalWellness,
      currentBehavior: 'Limited physical movement',
      suggestedBehavior: 'Walk for 15-20 minutes daily',
      expectedBenefit: 'Improved mood, better circulation, mental clarity',
      priority: 3,
      preferredTime: '17:00',
      minimumDurationMinutes: 15,
    );
  }
}
