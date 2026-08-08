import '../../domain/entities/habit_entity.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_remote_data_source.dart';
import '../models/habit_model.dart';

/// Data-layer implementation of [HabitRepository].
///
/// Converts between domain [HabitEntity] objects and data [HabitModel]
/// objects, while delegating all persistence to [HabitRemoteDataSource].
/// The repository does not access the Firestore SDK directly, which keeps it
/// independently testable with a fake or mocked data source.
class HabitRepositoryImpl implements HabitRepository {
  /// Creates a repository backed by the injected [remoteDataSource].
  HabitRepositoryImpl(this._remoteDataSource);

  final HabitRemoteDataSource _remoteDataSource;

  @override
  Future<List<HabitEntity>> getHabits(String uid) async {
    final models = await _remoteDataSource.getHabits(uid);
    return models.map(_toEntity).toList();
  }

  @override
  Future<HabitEntity?> getHabit(String uid, String id) async {
    final model = await _remoteDataSource.getHabit(uid, id);
    return model == null ? null : _toEntity(model);
  }

  @override
  Future<void> createHabit(String uid, HabitEntity habit) {
    return _remoteDataSource.createHabit(uid, _toModel(habit));
  }

  @override
  Future<void> updateHabit(String uid, HabitEntity habit) {
    return _remoteDataSource.updateHabit(uid, _toModel(habit));
  }

  @override
  Future<void> deleteHabit(String uid, String id) {
    return _remoteDataSource.deleteHabit(uid, id);
  }

  // ---------------------------------------------------------------------------
  // Private mapping helpers
  // ---------------------------------------------------------------------------

  HabitEntity _toEntity(HabitModel model) {
    return HabitEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      frequency: model.frequency,
      targetDays: model.targetDays,
      currentStreak: model.currentStreak,
      longestStreak: model.longestStreak,
      completedDates: model.completedDates,
      color: model.color,
      iconName: model.iconName,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  HabitModel _toModel(HabitEntity entity) {
    return HabitModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      frequency: entity.frequency,
      targetDays: entity.targetDays,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      completedDates: entity.completedDates,
      color: entity.color,
      iconName: entity.iconName,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
