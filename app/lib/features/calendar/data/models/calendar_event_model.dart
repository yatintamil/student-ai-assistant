import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/calendar_event_entity.dart';

class CalendarEventModel extends CalendarEventEntity {
  const CalendarEventModel({required super.id, required super.title, required super.startTime, required super.endTime, required super.isFlexible, super.recurrence, super.externalId, required super.createdAt, required super.updatedAt});

  factory CalendarEventModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    DateTime date(dynamic value) => value is Timestamp ? value.toDate() : DateTime.now();
    return CalendarEventModel(
      id: doc.id, title: data['title'] as String? ?? '', startTime: date(data['startTime']), endTime: date(data['endTime']),
      isFlexible: data['isFlexible'] as bool? ?? false,
      recurrence: CalendarRecurrence.values.firstWhere((v) => v.name == data['recurrence'], orElse: () => CalendarRecurrence.none),
      externalId: data['externalId'] as String?, createdAt: date(data['createdAt']), updatedAt: date(data['updatedAt']),
    );
  }
  factory CalendarEventModel.fromEntity(CalendarEventEntity e) => CalendarEventModel(id: e.id, title: e.title, startTime: e.startTime, endTime: e.endTime, isFlexible: e.isFlexible, recurrence: e.recurrence, externalId: e.externalId, createdAt: e.createdAt, updatedAt: e.updatedAt);
  Map<String, dynamic> toMap() => {'title': title, 'startTime': Timestamp.fromDate(startTime), 'endTime': Timestamp.fromDate(endTime), 'isFlexible': isFlexible, 'recurrence': recurrence.name, 'externalId': externalId, 'createdAt': Timestamp.fromDate(createdAt), 'updatedAt': Timestamp.fromDate(updatedAt)};
}
