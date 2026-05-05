import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gala_mobile/core/network/dio_error_message.dart';
import 'package:gala_mobile/features/interests/data/interests_repository.dart';
import 'package:gala_mobile/features/interests/data/models/interest.dart';
import 'package:gala_mobile/features/interests/presentation/cubit/interests_state.dart';

class InterestsCubit extends Cubit<InterestsState> {
  final InterestsRepository _repository;

  InterestsCubit({required InterestsRepository repository})
      : _repository = repository,
        super(const InterestsLoading());

  Future<void> load() async {
    emit(const InterestsLoading());
    try {
      final page = await _repository.listInterests();
      emit(InterestsLoaded(page.items));
    } catch (e) {
      emit(InterestsError(friendlyDioError(e)));
    }
  }

  Future<void> create({
    required String name,
    required String description,
    required InterestType type,
  }) async {
    await _repository.createInterest(
      name: name,
      description: description,
      type: type,
    );
    await load();
  }

  Future<void> delete(int id) async {
    await _repository.deleteInterest(id);
    await load();
  }
}
