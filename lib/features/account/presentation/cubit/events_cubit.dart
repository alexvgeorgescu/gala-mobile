import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gala_mobile/core/network/dio_error_message.dart';
import 'package:gala_mobile/features/account/data/events_repository.dart';
import 'package:gala_mobile/features/account/data/models/event.dart';
import 'package:gala_mobile/features/account/presentation/cubit/events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final EventsRepository _repository;

  EventsCubit({required EventsRepository repository})
      : _repository = repository,
        super(const EventsLoading());

  Future<void> load() async {
    emit(const EventsLoading());
    try {
      final page = await _repository.listEvents();
      emit(EventsLoaded(page.items));
    } catch (e) {
      emit(EventsError(friendlyDioError(e)));
    }
  }

  Future<void> create({
    required String name,
    required DateTime date,
    Recurrence? recurrence,
  }) async {
    await _repository.createEvent(
      name: name,
      date: date,
      recurrence: recurrence,
    );
    await load();
  }

  Future<void> delete(int id) async {
    await _repository.deleteEvent(id);
    await load();
  }
}
