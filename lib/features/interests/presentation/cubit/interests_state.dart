import 'package:equatable/equatable.dart';
import 'package:gala_mobile/features/interests/data/models/interest.dart';

sealed class InterestsState extends Equatable {
  const InterestsState();

  @override
  List<Object?> get props => [];
}

class InterestsLoading extends InterestsState {
  const InterestsLoading();
}

class InterestsLoaded extends InterestsState {
  final List<Interest> interests;

  const InterestsLoaded(this.interests);

  @override
  List<Object?> get props => [interests];
}

class InterestsError extends InterestsState {
  final String message;

  const InterestsError(this.message);

  @override
  List<Object?> get props => [message];
}
