import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event_model.dart';

abstract interface class CalendarRemoteDataSource {
  Future<List<CalendarEventModel>> getEvents(String userId, DateTime start, DateTime end);
  Future<void> saveEvent(String userId, CalendarEventModel event);
  Future<void> deleteEvent(String userId, String eventId);
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  CalendarRemoteDataSourceImpl({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> _events(String uid) => _firestore.collection('users').doc(uid).collection('calendar_events');
  @override
  Future<List<CalendarEventModel>> getEvents(String uid, DateTime start, DateTime end) async {
    final result = await _events(uid).where('startTime', isLessThan: Timestamp.fromDate(end)).get();
    return result.docs.map(CalendarEventModel.fromFirestore).where((event) => event.endTime.isAfter(start)).toList()..sort((a,b) => a.startTime.compareTo(b.startTime));
  }
  @override Future<void> saveEvent(String uid, CalendarEventModel event) => _events(uid).doc(event.id).set(event.toMap());
  @override Future<void> deleteEvent(String uid, String id) => _events(uid).doc(id).delete();
}
