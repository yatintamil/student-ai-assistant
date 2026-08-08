import '../../domain/entities/habit_entity.dart';

/// An immutable snapshot of the habit feature state.
class HabitState {
  const HabitState._({
    this.habits = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  /// Creates the initial state with an empty habit list and no error.
  factory HabitState.initial() => const HabitState._();

  /// Creates a state representing an active habit operation.
  factory HabitState.loading() => const HabitState._(isLoading: true);

  /// Creates a state containing the successfully loaded [habits].
  factory HabitState.loaded(List<HabitEntity> habits) =>
      HabitState._(habits: habits);

  /// Creates a failure state containing [message].
  factory HabitState.error(String message) =>
      HabitState._(errorMessage: message);

  /// The current list of habits. Empty until successfully loaded.
  final List<HabitEntity> habits;

  /// Whether a habit operation is currently in progress.
  final bool isLoading;

  /// A message describing the latest habit operation failure, if any.
  final String? errorMessage;

  /// Returns a copy of this state with the supplied fields replaced.
  HabitState copyWith({
    List<HabitEntity>? habits,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HabitState._(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HabitState &&
            other.isLoading == isLoading &&
            other.errorMessage == errorMessage &&
            _listEquals(other.habits, habits);
  }

  @override
  int get hashCode => Object.hash(habits, isLoading, errorMessage);

  static bool _listEquals(List<HabitEntity> a, List<HabitEntity> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
