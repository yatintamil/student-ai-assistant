import 'package:equatable/equatable.dart';

/// A user-managed calendar event. Non-flexible events block the planner.
class CalendarEventEntity extends Equatable {
  const CalendarEventEntity({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.isFlexible,
    this.recurrence = CalendarRecurrence.none,
    this.externalId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final bool isFlexible;
  final CalendarRecurrence recurrence;
  /// Provider event id for imported events. Local events leave this null.
  final String? externalId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Duration get duration => endTime.difference(startTime);
  bool overlaps(DateTime start, DateTime end) =>
      startTime.isBefore(end) && endTime.isAfter(start);

  CalendarEventEntity copyWith({
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    bool? isFlexible,
    CalendarRecurrence? recurrence,
    String? externalId,
    DateTime? updatedAt,
  }) => CalendarEventEntity(
    id: id,
    title: title ?? this.title,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    isFlexible: isFlexible ?? this.isFlexible,
    recurrence: recurrence ?? this.recurrence,
    externalId: externalId ?? this.externalId,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [id, title, startTime, endTime, isFlexible, recurrence, externalId, createdAt, updatedAt];
}

enum CalendarRecurrence { none, daily, weekly }
