import '../../domain/entities/calendar_event_entity.dart';
class CalendarState { const CalendarState({this.events = const [], this.isLoading = false, this.errorMessage}); final List<CalendarEventEntity> events; final bool isLoading; final String? errorMessage;
  CalendarState copyWith({List<CalendarEventEntity>? events, bool? isLoading, String? errorMessage}) => CalendarState(events: events ?? this.events, isLoading: isLoading ?? this.isLoading, errorMessage: errorMessage);
}
