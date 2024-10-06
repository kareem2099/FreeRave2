import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freerave/main_screens/home_screen/connections/models/user_model.dart';
import 'package:freerave/main_screens/profile/cubit/profile_service.dart';

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _profileService;

  ProfileCubit(this._profileService) : super(ProfileInitial());

  Future<void> loadUserProfile() async {
    try {
      emit(ProfileLoading());
      final userModel = await _profileService.getUserProfile();
      emit(ProfileLoaded(userModel));
    } catch (e) {
      emit(ProfileError(_handleError(e)));
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      emit(ProfileUpdating());
      await _profileService.updateUserProfile(updatedUser);
      emit(ProfileUpdated());
      loadUserProfile(); // Optimization: Alternatively, directly emit `ProfileLoaded(updatedUser)`
    } catch (e) {
      emit(ProfileError(_handleError(e)));
    }
  }

  String _handleError(dynamic e) {
    // Customize error messages for common scenarios
    if (e is FirebaseException && e.code == 'permission-denied') {
      return 'You do not have permission to update the profile.';
    }
    return e.toString();
  }
}
