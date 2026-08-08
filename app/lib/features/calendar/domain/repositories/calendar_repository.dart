import '../entities/calendar_event_entity.dart';

abstract interface class CalendarRepository {
  Future<List<CalendarEventEntity>> getEvents(String userId, DateTime start, DateTime end);
  Future<void> saveEvent(String userId, CalendarEventEntity event);
  Future<void> deleteEvent(String userId, String eventId);
}
