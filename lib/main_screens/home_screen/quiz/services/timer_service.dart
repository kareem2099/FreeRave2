import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/timer_model.dart';

class TimerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setTimer(TimerSetting timerSetting) async {
    try {
      await _firestore.collection('timer_settings').doc(timerSetting.id).set(timerSetting.toMap());
    } catch (e) {
      throw Exception('Failed to set timer: $e');
    }
  }

  Future<TimerSetting> getTimer(String questionId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('timer_settings')
          .where('questionId', isEqualTo: questionId)
          .get();
      return TimerSetting.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch timer: $e');
    }
  }
}
