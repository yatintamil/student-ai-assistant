import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../providers/calendar_providers.dart';
import '../states/calendar_state.dart';

class CalendarController extends Notifier<CalendarState> {
  late CalendarRepository _repository;
  @override CalendarState build() { _repository = ref.read(calendarRepositoryProvider); return const CalendarState(); }
  Future<void> loadEvents(String uid, {DateTime? start, DateTime? end}) async { state = state.copyWith(isLoading: true, errorMessage: null); final from = start ?? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day); final to = end ?? from.add(const Duration(days: 7)); try { state = CalendarState(events: await _repository.getEvents(uid, from, to)); } catch (e) { state = CalendarState(events: state.events, errorMessage: 'Failed to load calendar: $e'); } }
  Future<void> saveEvent(String uid, CalendarEventEntity event) async { try { await _repository.saveEvent(uid, event); await loadEvents(uid); } catch (e) { state = state.copyWith(errorMessage: 'Failed to save event: $e'); } }
  Future<void> deleteEvent(String uid, String id) async { try { await _repository.deleteEvent(uid, id); await loadEvents(uid); } catch (e) { state = state.copyWith(errorMessage: 'Failed to delete event: $e'); } }
}
