import 'package:equatable/equatable.dart';
import 'package:gala_mobile/features/members/data/models/member.dart';

sealed class MemberSearchState extends Equatable {
  const MemberSearchState();

  @override
  List<Object?> get props => [];
}

class MemberSearchIdle extends MemberSearchState {
  const MemberSearchIdle();
}

class MemberSearchLoading extends MemberSearchState {
  final String query;

  const MemberSearchLoading(this.query);

  @override
  List<Object?> get props => [query];
}

class MemberSearchLoaded extends MemberSearchState {
  final String query;
  final List<Member> members;

  const MemberSearchLoaded(this.query, this.members);

  @override
  List<Object?> get props => [query, members];
}

class MemberSearchError extends MemberSearchState {
  final String query;
  final String message;

  const MemberSearchError(this.query, this.message);

  @override
  List<Object?> get props => [query, message];
}
