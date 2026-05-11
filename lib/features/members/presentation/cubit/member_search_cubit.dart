import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gala_mobile/core/network/dio_error_message.dart';
import 'package:gala_mobile/features/members/data/members_repository.dart';
import 'package:gala_mobile/features/members/presentation/cubit/member_search_state.dart';

class MemberSearchCubit extends Cubit<MemberSearchState> {
  static const _debounceDuration = Duration(milliseconds: 400);
  static const _minChars = 2;

  final MembersRepository _repository;

  Timer? _debounce;
  int _searchSeq = 0;
  String _currentQuery = '';

  MemberSearchCubit({required MembersRepository repository})
      : _repository = repository,
        super(const MemberSearchIdle());

  void onQueryChanged(String raw) {
    final query = raw.trim();
    _currentQuery = query;
    _debounce?.cancel();

    if (query.length < _minChars) {
      // Invalidate any in-flight request so a late response can't overwrite Idle.
      _searchSeq++;
      emit(const MemberSearchIdle());
      return;
    }

    _debounce = Timer(_debounceDuration, () => _runSearch(query));
  }

  Future<void> retry() async {
    if (_currentQuery.length < _minChars) return;
    await _runSearch(_currentQuery);
  }

  Future<void> _runSearch(String query) async {
    final token = ++_searchSeq;
    emit(MemberSearchLoading(query));
    try {
      final page = await _repository.search(search: query);
      if (token != _searchSeq) return;
      emit(MemberSearchLoaded(query, page.items));
    } catch (e) {
      if (token != _searchSeq) return;
      emit(MemberSearchError(query, friendlyDioError(e)));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
