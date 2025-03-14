import 'package:flutter_auth_app/models/userDTO.dart';
import 'package:flutter_auth_app/models/userList.dart';

class AuthService {
  final UserList _userList = UserList();

  Future<bool> login(String username, String password) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    for (var user in _userList.users) {
      if (user.username == username && user.password == password) {
        return true;
      }
    }
    return false;
  }

  Future<bool> register(String username, String password) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    if (_userList.userExists(username)) {
      return false; // User already exists
    } else {
      _userList.addUser(UserDTO(username: username, password: password));
      return true;
    }
  }
}