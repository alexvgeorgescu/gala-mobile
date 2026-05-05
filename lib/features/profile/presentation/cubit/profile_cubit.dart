import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gala_mobile/core/storage/secure_storage.dart';
import 'package:gala_mobile/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final SecureStorage _storage;

  ProfileCubit({required SecureStorage storage})
      : _storage = storage,
        super(const ProfileLoading());

  Future<void> loadProfile() async {
    try {
      final email = await _storage.readUserEmail() ?? '';
      final fullName = await _storage.readUserFullName() ?? '';
      emit(ProfileLoaded(email: email, fullName: fullName));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
