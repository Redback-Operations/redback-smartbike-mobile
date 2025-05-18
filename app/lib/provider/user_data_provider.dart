import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phone_app/models/user_details.dart';
import 'package:phone_app/provider/user_session_provider.dart';
import 'package:provider/provider.dart';

class UserDataProvider extends ChangeNotifier {
  // Private static instance of UserDataProvider
  static final UserDataProvider _instance = UserDataProvider._internal();

  // Private constructor
  UserDataProvider._internal();

  // Factory constructor to return the singleton instance
  factory UserDataProvider() {
    return _instance;
  }

  UserDetails? _userDetails;

  UserDetails? get userDetails => _userDetails;

  void updateUserDetails(
      BuildContext context, {
        String? email,
        String? username,
        String? name,
        String? surname,
        String? dob,
        String? phoneNumber,
        String? imagePath,
        String? id,
      }) {
    _userDetails = UserDetails(
      email: email ?? _userDetails?.email ?? '',
      username: username ?? _userDetails?.username ?? '',
      name: name ?? _userDetails?.name ?? '',
      surname: surname ?? _userDetails?.surname ?? '',
      dob: dob ?? _userDetails?.dob ?? '',
      phoneNumber: phoneNumber ?? _userDetails?.phoneNumber ?? '',
      imagePath: imagePath ?? _userDetails?.imagePath ?? '',
      id: id ?? _userDetails?.id ?? '',
    );

    // Save the updated user details securely
    final sessionProvider = context.read<UserSessionProvider>();
    sessionProvider.saveUserSession(
      email: _userDetails?.email,
      username: _userDetails?.username,
      name: _userDetails?.name,
      surname: _userDetails?.surname,
      dob: _userDetails?.dob,
      phoneNumber: _userDetails?.phoneNumber,
      imagePath: _userDetails?.imagePath,
      id: _userDetails?.id,
    );

    notifyListeners();
  }

  Future<void> loadUserDetails(UserSessionProvider sessionProvider) async {
    _userDetails = UserDetails(
      email: sessionProvider.email ?? '',
      username: sessionProvider.username ?? '',
      name: sessionProvider.name ?? '',
      surname: sessionProvider.surname ?? '',
      dob: sessionProvider.dob ?? '',
      phoneNumber: sessionProvider.phoneNumber ?? '',
      imagePath: sessionProvider.imagePath ?? '',
      id: sessionProvider.id ?? '',
    );
    if (kDebugMode) {
      print("Data Loaded - Data $_userDetails ");
    }
    notifyListeners();
  }

  Future<void> clearSession(UserSessionProvider sessionProvider) async {
    await sessionProvider.clearUserSession();
    _userDetails = null;
    notifyListeners();
  }
}