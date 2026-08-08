import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_data_source.dart';
import '../models/calendar_event_model.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  const CalendarRepositoryImpl(this._source); final CalendarRemoteDataSource _source;
  @override Future<List<CalendarEventEntity>> getEvents(String uid, DateTime start, DateTime end) => _source.getEvents(uid, start, end);
  @override Future<void> saveEvent(String uid, CalendarEventEntity event) => _source.saveEvent(uid, CalendarEventModel.fromEntity(event));
  @override Future<void> deleteEvent(String uid, String id) => _source.deleteEvent(uid, id);
}
