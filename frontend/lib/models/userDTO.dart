class UserDTO {
  final String username;
  final String password;
  final String? roles; // roles es opcional para el login

  UserDTO({
    required this.username,
    required this.password,
    this.roles,
  });

  // Convierte el objeto a un mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'roles': roles,
    };
  }
}