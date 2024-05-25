import 'package:flutter/material.dart';
import 'package:phone_app/models/user_details.dart';

class UserDataProvider extends ChangeNotifier {
  UserDetails? _userDetails;

  UserDetails? get userDetails => _userDetails;

  void updateUserDetails({
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
    notifyListeners();
  }

  Future<void> clearSession() async {
    // clear user session
    _userDetails = null;
    notifyListeners();
  }
}
