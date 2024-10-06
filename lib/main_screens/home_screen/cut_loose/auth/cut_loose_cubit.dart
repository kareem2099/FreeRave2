import 'package:flutter_bloc/flutter_bloc.dart';
import 'cut_loose_state.dart';
import 'firebase_service.dart';

class CutLooseCubit extends Cubit<CutLooseState> {
  final FirebaseService firebaseService;

  CutLooseCubit(this.firebaseService) : super(CutLooseInitial());

  void loadMessages() async {
    try {
      emit(CutLooseLoading());
      final messages = await firebaseService.getMessages();
      emit(CutLooseLoaded(messages));
    } catch (e) {
      emit(CutLooseError(e.toString()));
    }
  }

  void addMessage(String message) async {
    try {
      await firebaseService.addMessage(message);
      loadMessages();
    } catch (e) {
      emit(CutLooseError(e.toString()));
    }
  }
}
