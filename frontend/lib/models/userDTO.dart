class UserDTO {
  final String username;
  final String password;

  UserDTO({
    required this.username,
    required this.password,
  });

  // Convierte el objeto a un mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}