import 'package:flutter_auth_app/models/userDTO.dart';

class UserList {
  final List<UserDTO> _users = [
    UserDTO(username: 'juancuel', password: 'password1'),
    UserDTO(username: 'jdelgadoc', password: 'password2'),
    UserDTO(username: 'svasco', password: 'password3'),
    UserDTO(username: 'j', password: 'j'),
  ];

  List<UserDTO> get users => _users;

  void addUser(UserDTO user) {
    _users.add(user);
  }

  bool userExists(String username) {
    return _users.any((user) => user.username == username);
  }
}