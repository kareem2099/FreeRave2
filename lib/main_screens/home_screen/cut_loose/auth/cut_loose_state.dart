abstract class CutLooseState {}

class CutLooseInitial extends CutLooseState {}

class CutLooseLoading extends CutLooseState {}

class CutLooseLoaded extends CutLooseState {
  final List<String> messages;

  CutLooseLoaded(this.messages);
}

class CutLooseError extends CutLooseState {
  final String message;

  CutLooseError(this.message);
}
