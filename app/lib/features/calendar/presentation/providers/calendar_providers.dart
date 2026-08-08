import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/calendar_remote_data_source.dart';
import '../../data/repositories/calendar_repository_impl.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../controllers/calendar_controller.dart';
import '../states/calendar_state.dart';
final calendarRemoteDataSourceProvider = Provider<CalendarRemoteDataSource>((ref) => CalendarRemoteDataSourceImpl());
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) => CalendarRepositoryImpl(ref.watch(calendarRemoteDataSourceProvider)));
final calendarControllerProvider = NotifierProvider<CalendarController, CalendarState>(CalendarController.new);
