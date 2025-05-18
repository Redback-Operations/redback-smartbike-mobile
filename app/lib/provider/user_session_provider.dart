import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSessionProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  // User data fields
  String? _email;
  String? _username;
  String? _name;
  String? _surname;
  String? _dob;
  String? _phoneNumber;
  String? _imagePath;
  String? _id;

  // Getters
  String? get email => _email;

  String? get username => _username;

  String? get name => _name;

  String? get surname => _surname;

  String? get dob => _dob;

  String? get phoneNumber => _phoneNumber;

  String? get imagePath => _imagePath;

  String? get id => _id;

  // Method to save user session data securely
  Future<void> saveUserSession({
    String? email,
    String? username,
    String? name,
    String? surname,
    String? dob,
    String? phoneNumber,
    String? imagePath,
    String? id,
  }) async {
    _email = email;
    _username = username;
    _name = name;
    _surname = surname;
    _dob = dob;
    _phoneNumber = phoneNumber;
    _imagePath = imagePath;
    _id = id;

    await _storage.write(key: 'email', value: _email);
    await _storage.write(key: 'username', value: _username);
    await _storage.write(key: 'name', value: _name);
    await _storage.write(key: 'surname', value: _surname);
    await _storage.write(key: 'dob', value: _dob);
    await _storage.write(key: 'phoneNumber', value: _phoneNumber);
    await _storage.write(key: 'imagePath', value: _imagePath);
    await _storage.write(key: 'id', value: _id);

    notifyListeners(); // Notify listeners to update UI
  }

  // Method to load user session data securely
  Future<void> loadUserSession() async {
    _email = await _storage.read(key: 'email');
    _username = await _storage.read(key: 'username');
    _name = await _storage.read(key: 'name');
    _surname = await _storage.read(key: 'surname');
    _dob = await _storage.read(key: 'dob');
    _phoneNumber = await _storage.read(key: 'phoneNumber');
    _imagePath = await _storage.read(key: 'imagePath');
    _id = await _storage.read(key: 'id');

    if (kDebugMode) {
      print(
          "Session Load - Data $_email | $_dob | $_id | $_imagePath | $_name | $_phoneNumber | $_surname | $_username ");
    }
    notifyListeners();
  }

  // Method to clear user session data securely
  Future<void> clearUserSession() async {
    _email = null;
    _username = null;
    _name = null;
    _surname = null;
    _dob = null;
    _phoneNumber = null;
    _imagePath = null;
    _id = null;

    await _storage.delete(key: 'email');
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'name');
    await _storage.delete(key: 'surname');
    await _storage.delete(key: 'dob');
    await _storage.delete(key: 'phoneNumber');
    await _storage.delete(key: 'imagePath');
    await _storage.delete(key: 'id');

    notifyListeners();
  }

  // Check if user session exists
  bool get isLoggedIn => _id != null; // Assuming 'id' indicates login state
}
